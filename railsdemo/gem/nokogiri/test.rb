require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('http://www.iteye.com/topic/557485'))

puts doc
'body markdown-body entry-content'
