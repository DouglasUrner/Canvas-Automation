require 'bundler/setup'
require 'henkei'
require 'nokogiri'

pdf = ARGV.pop

repo = Nokogiri::HTML(Yomu.new(pdf).html).xpath('//div[@class="annotation"]/a/@href')
#puts submission

p repo
p repo.length
