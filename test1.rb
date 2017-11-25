require 'open-uri'
require 'nokogiri'
require 'byebug'
require 'gmail'

# logic for bringing this single list of the instruments will be following
#  1. I think i should try to find a single insutrument which is in all lists.(It can be many)
#  2. That Instrument should be below 500yen (price should be configurable)
#  3. If there is no instrument like that then use below algorithm
#         a) remove 値上がり and compare the other 5 lists for the above algorithm
#  4. If still is there is no instruement then use below algorightm
#         a) remove 値上がり and 今週の値上がり compare the other 4 lists for the above algorithm
#  5. If still is there is no instruement then use below algorightm
#         a) remove 値上がり and 今週の値上がり and 株価検索急増 compare the other 3 lists for the above algorithm
#  6. If still is there is no instruement then use below algorightm
#         a) remove 値上がり and 今週の値上がり and 株価検索急増 and PBR高位 compare the other 2 lists for the above algorithm
#  7. When you are returning the list it should also explain which list it compared so that i get the probability number more accurate
#  8. I can come up with the probability scale based on which list i compared.
#  9. This probability stats should be based on below logic
      #  A) Name of the list which it compared to get the results
      #  B) The rank of that instruement in each list and actual % value.
      #  C) If i have the instruement from the PBR list then i should check whether the PBR is too high or too low
      #  D)
# high ROE buy high ROA buy
#detail = []
class Test1
  toppage = []
  alldata = []

  def getTopPage()
    topData = []
    detail = []
    totalData = []
    stockData = []
    stockcodeData = []
    doc = open('https://www.nikkei.com/markets/ranking/')
    #page = open('http://www.nokogiri.org/tutorials/installing_nokogiri.html')
    website = Nokogiri::HTML(doc)
    #ranking = doc.css('ul#st01 yjS').css('li')
    toppage = website.css('ul.m-newsList').css('li').css('a')
    urlcount = toppage.length
    puts urlcount
    i = 4
    while i <= 49 # changed for the all the URLs
      title = toppage[i].content
      if title == "値上がり" or title == "今週の値上がり" or title == "前月比値上がり" or title == "株価検索急増" or title == "予想PER高位" or title == "PBR高位"
        url = toppage[i].values
        ss = 'https://www.nikkei.com'
        ss.concat(url[0])
        eachpage = open(ss)
        webpage = Nokogiri::HTML(eachpage)
        topData = retrievedata(webpage, title)
        stockcodeData = retrievestockcodes(webpage, title)
        stockData.push(*stockcodeData)
        totalData.push(*topData)
      end #end of if
      i+=1
    end #end of while
    val1 = getUniquestockcodes(stockData)
    val2 = getStockInformation(val1,totalData)
    return val2
  end # end of getTopPage

  def getUniquestockcodes(stockData)
    val = stockData.select {|e| stockData.count(e) > 1}.uniq
    return val
  end #end of getUniquestockcodes

  def getStockInformation(stockData,totalData)
    count = stockData.length
    stockinfo = []
    i = 0;
    # below hardcoding is needed for setting up the the header and title information
    stockinfo.push("Title")
    stockinfo.push("順位")
    stockinfo.push("証券コード")
    stockinfo.push("銘柄名")
    stockinfo.push("値上がり率(%)")
    stockinfo.push("現在値（円）")
    stockinfo.push("前日比（円）")
    for i in 0 .. count
        indexval = totalData.index stockData[i]
        if indexval != nil
          stockinfo.push(totalData[indexval-1])
          stockinfo.push(totalData[indexval])
          stockinfo.push(totalData[indexval+1])
          stockinfo.push(totalData[indexval+2])
          stockinfo.push(totalData[indexval+3])
          stockinfo.push(totalData[indexval+4])
        end #end of if
        i+=1
    end #end of for
    return stockinfo
  end # end of getStockInformation

  def retrievestockcodes(webpage,title)
    headers =[]
    top = []
    webpage.xpath('//*/table[@class="tblModel-1"]/thead/tr/th') .each do |th|
      headers <<  th.text
    end #end of th do
    top.push(title)
    #top.push(headers[1],headers[2],headers[3],headers[4],headers[5],headers[6])
    rows = webpage.xpath('//*/table[@class="tblModel-1"]/tbody/tr')
    details = rows.collect do |row|
    [
      #[headers[1],'td[2]/text()'],
      [headers[2],'td[3]/a/text()'],
      #[headers[3],'td[4]/a/text()'],
      #[headers[4],'td[5]/text()'],
      #[headers[5],'td[6]/text()'],
      #[headers[6],'td[7]/span/text()'],
    ].each do |name, xpath|
          contents = []
          detail = row.at_xpath(xpath).to_s.strip
          contents.push(*detail)
          top.push(*contents)
        end # end of xpath do
      end # end of row do
      return top
  end # end of retrievestockcodes

  def retrievedata(webpage,title)
    headers =[]
    top = []
    webpage.xpath('//*/table[@class="tblModel-1"]/thead/tr/th') .each do |th|
      headers <<  th.text
    end #end of th do
    top.push(title)
    top.push(headers[1],headers[2],headers[3],headers[4],headers[5],headers[6])
    rows = webpage.xpath('//*/table[@class="tblModel-1"]/tbody/tr')
    details = rows.collect do |row|
    [
      [headers[1],'td[2]/text()'],
      [headers[2],'td[3]/a/text()'],
      [headers[3],'td[4]/a/text()'],
      [headers[4],'td[5]/text()'],
      [headers[5],'td[6]/text()'],
      [headers[6],'td[7]/span/text()'],
    ].each do |name, xpath|
          contents = []
          detail = row.at_xpath(xpath).to_s.strip
          contents.push(*detail)
          top.push(*contents)
        end # end of xpath do
      end # end of row do
      return top
  end # end of retrievedata

  def ToTitle(topArray)
    titles = "<title>#{topArray[0]}</title>"
  end # end of ToTitle

  def ToHeader(topArray)
    head =""
    iN = 1
    while iN <= 6
      head.concat("<th>#{topArray[iN].to_s.strip}</th>")
      iN+=1
    end
    return head
  end #end of ToHeader

  def ToRows(topArray)
    data = "<tr>"
    n = 1
    for iNumber in 7 .. topArray.length-1
      data.concat("<td>#{topArray[iNumber]}</td>")
      if n % 6 == 0
          data.concat("</tr>")
          if iNumber != topArray.length-1
            data.concat("<tr>")
          end #end of if
      end #end of if
      n += 1
    end # end of for
    return data
  end #end of ToRows

  def sendEmail(dataset)
    username = 'test60482@gmail.com'
    password = 'testing123'
    gmail = Gmail.connect(username, password)
    #  gmail.logout
        gmail.deliver do
          to "test60482@gmail.com"
          subject "Today tips!"
          text_part do
              body dataset
          end # end of the text part
          html_part do
              content_type 'text/html; charset=UTF-8'
              body dataset
          end # end of the HTMl part
        #add_file "/path/to/some_image.jpg"
        end #end of do
  end# end of sendemail
end #end of class

var1 = Test1.new
#compare the different lists in this function and return the final result to the gmail.
alldata = var1.getTopPage()
table =""
table1 = "<html>#{var1.ToTitle(alldata)}<body>"
table2 ="<table>#{var1.ToHeader(alldata)}"
table3 ="#{var1.ToRows(alldata)}</table></body></html>"
table.concat(table1)
table.concat(table2)
table.concat(table3)
#puts table
var1.sendEmail(table)
