require 'open-uri'
require 'nokogiri'
require 'byebug'

page = open('https://info.finance.yahoo.co.jp/ranking/?kd=1&tm=d&mk=1')

doc = Nokogiri::HTML(page)
#byebug

doc.css('#priceblock_ourprice').each do |price|
  puts price.content
#system.out.print(price)
end
