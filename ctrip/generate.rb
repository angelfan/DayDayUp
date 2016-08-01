# encoding: UTF-8
require 'addressable'
require 'nokogiri'
require 'open-uri'
require 'httparty'
require 'csv'

class Generator
  attr_reader :dist_name, :url, :file_name
  HEADER = %w(Country VendorName VehicleEName Transmission MinPrice).freeze

  def initialize(dist_name, url, file_name)
    id = Addressable::URI.parse(url).query_values['id']
    @dist_name = dist_name
    @url = "http://w.zuzuche.com/list_new_json.php?id=#{id}"
    @file_name = File.dirname(__FILE__).concat("/#{file_name}")
  end

  def generate
    CSV.open("#{file_name}.csv", 'wb') do |csv|
      csv << HEADER
      res = HTTParty.get("#{url}")
      res['data']['shop'].map {|s| [s[1]['name'], s[1]['dealer_id']]}.uniq.each do |s|
        vendor_name = s[0]
        dealer_id = s[1]
        body = HTTParty.get("#{url}&dealer=#{dealer_id}")
        body['data']['list'].each do |d|
          csv << [
              dist_name,
              vendor_name,
              d['name_en'],
              d['transmission'] == 1 ? '自动挡' : '手动挡',
              d['min_price'],
          ]
        end
      end
    end
  end
end

Generator.new('德文波特', 'http://w.zuzuche.com/list_new_json.php?id=37461474', 'dewen').generate




