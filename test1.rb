#byebug
require 'open-uri'
require 'nokogiri'
require 'byebug'
require 'gmail'

doc = open('https://www.nikkei.com/markets/ranking/')
#page = open('http://www.nokogiri.org/tutorials/installing_nokogiri.html')

website = Nokogiri::HTML(doc)
#ranking = doc.css('ul#st01 yjS').css('li')
toppage = website.css('ul.m-newsList').css('li').css('a')
urlcount = toppage.length
i = 4
detail = []
top = []
table =""
  while i <= 4
    title = toppage[i].content
    #puts title
    if title == "値上がり" or title == "今週の値上がり" or title == "前月比値上がり" or title == "株価検索急増" or title == "予想PER高位" or title == "PBR高位"
      url = toppage[i].values
      ss = 'https://www.nikkei.com'
      ss.concat(url[0])
      eachpage = open(ss)
      webpage = Nokogiri::HTML(eachpage)
      #webpage = website.xpath('//table[@class="tblModel-1"]/tr/td/..').map do |row|
        headers =[]
        webpage.xpath('//*/table[@class="tblModel-1"]/thead/tr/th') .each do |th|
          headers <<  th.text
        end #end of th do
        top.push(title)
        top.push(headers[1],headers[2],headers[3],headers[4],headers[5],headers[6])
        #top.push(headers)
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
          # high P/E ratio to buy | High PBR buy | Too high and too low PBR is to avoid
          # high ROE buy high ROA buy
        end # end of row do
        #puts contents
    end #end of if
    i+=1
  end #end of while
  #top.push(*contents)
  puts top.length

  def ToTitle(topArray)
      titles = "<title>#{topArray[0]}</title>"
  end

  def ToHeader(topArray)
    head =""
    iN = 1
    while iN <= 6
      head.concat("<th>#{topArray[iN].to_s.strip}</th>")
      iN+=1
    end
    return head
  end

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
  end

  table1 = "<html>#{ToTitle(top)}<body>"
  table2 ="<table>#{ToHeader(top)}"
  table3 ="#{ToRows(top)}</table></body></html>"
  table.concat(table1)
  table.concat(table2)
  table.concat(table3)

begin
  username = 'test60482@gmail.com'
  password = 'testing123'

  gmail = Gmail.connect(username, password)
  #  gmail.logout
      gmail.deliver do
        to "test60482@gmail.com"
        subject "Today tips!"
        text_part do
            body table
          end
        html_part do
            content_type 'text/html; charset=UTF-8'
            body table
        end
      #add_file "/path/to/some_image.jpg"
      end #end of do
 end
