#byebug
require 'open-uri'
require 'nokogiri'
require 'byebug'
require 'net/smtp'
require 'tlsmail'

doc = open('https://www.nikkei.com/markets/ranking/')
#page = open('http://www.nokogiri.org/tutorials/installing_nokogiri.html')

website = Nokogiri::HTML(doc)
#ranking = doc.css('ul#st01 yjS').css('li')
toppage = website.css('ul.m-newsList').css('li').css('a')
urlcount = toppage.length
  i = 4
  while i <= urlcount-25
    title = toppage[i].content
    puts title
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
        end#end of do
        #website.xpath('//*/table[@class="tblModel-1"]/tbody/tr').each_with_index do |row, y|
        rows = webpage.xpath('//*/table[@class="tblModel-1"]/tbody/tr')
        details = rows.collect do |row|
          detail = {}
          [
            [headers[1],'td[2]/text()'],
            [headers[2],'td[3]/a/text()'],
            [headers[3],'td[4]/a/text()'],
            [headers[4],'td[5]/text()'],
            [headers[5],'td[6]/text()'],
            [headers[6],'td[7]/span/text()'],
          ].each do |name, xpath|
              detail[name] = row.at_xpath(xpath).to_s.strip
            end # end of do
          #detail
          detail.each do |key, value|
            puts key
            puts value
          end #end of hash

          #byebug
          # high P/E ratio to buy | High PBR buy | Too high and too low PBR is to avoid
          # high ROE buy high ROA buy
          #webpage = website.xpath('//table[@class="tblModel-1"]/..').map do |row|
        end # end of do
    end #end of if
    #puts "this is me"
    i+=1
  end #end of while
