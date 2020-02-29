require 'yomu'
require 'nokogiri'

pdf = ARGV.pop

submission = Nokogiri::HTML(Yomu.new(pdf).html)
#puts submission

puts submission.xpath('//div[@class="annotation"]/a/@href')
