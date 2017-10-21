#byebug
require 'open-uri'
require 'nokogiri'
require 'byebug'

doc = open('https://www.nikkei.com/markets/ranking/')
#page = open('http://www.nokogiri.org/tutorials/installing_nokogiri.html')

website = Nokogiri::HTML(doc)
#ranking = doc.css('ul#st01 yjS').css('li')
toppage = website.css('ul.m-newsList').css('li').css('a')
urlcount = toppage.length
  i = 5
  while i <= urlcount-5
    title = toppage[i].content
    url = toppage[i].values
    ss = 'https://www.nikkei.com'
    ss.concat(url[0])
    eachpage = open(ss)
    webpage = Nokogiri::HTML(eachpage)
    #webpage = website.xpath('//table[@class="tblModel-1"]/tr/td/..').map do |row|
        headers =[]
        webpage.xpath('//*/table[@class="tblModel-1"]/thead/tr/th') .each do |th|
        headers <<  th.text
      end
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
          end
          detail
          puts detail
          #byebug
          #webpage = website.xpath('//table[@class="tblModel-1"]/..').map do |row|
    end
    i+=1
  end
