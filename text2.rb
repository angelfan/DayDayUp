# def get_col_data(table_data, column_num)
#   col_data = []
#   table_data.each do |data|
#     col_data << data[column_num]
#   end
#   col_data
# end
#
# def column_is_asc(data)
#
# end
# table_data = [ [1,2,3], [2, "2", "3"] ]
# col_data = get_col_data(table_data, 2)
# p col_data
#
# arr = [1, 2, 3, 4, 5]
# b = arr.select do |aaa|
#   aaa == 1
#   aaa
# end
#
# p b
#
#

# def a1(a)
#  a == 2
# end
#
# def b2
#   p a1(2)
#   a = 2
#   return if a1(2)
#   p 2
# end

# a = [{a: 1}, {b: 2}, {c: 3}]
# b = a.delete_if{ |key| key.keys[0] == :a }
# p b.map(&:first)

# class TestName
#   include Redis
#
#   attr_accessor :name
#
#   def initialize(name)
#     @name = name
#   end
# end
#
# module Redis
#   def get
#     key
#   end
#
#   def set
#     Test
#   end
#
#   def key
#     return nil if name.nil?
#     ['name', name].join(':')
#   end
# end
#
# class Name
#   class << self
#     def change
#       Hello.new('angel').migrate
#     end
#   end
#
#   class Hello
#     include Redis
#
#     attr_reader :name
#     def initialize(name1)
#       @name1 = name1
#     end
#
#     def migrate
#       @name = @name1
#     end
#   end
# end
# require 'httparty'
# response = HTTParty.get('https://api.stackexchange.com/2.2/questions?site=stackoverflow')
#
# puts response.body
# puts response.code
# puts response.message
# puts response.headers.inspect

#
# def extra_params
#   { extra: {} }
# end
#
# def alipay_wap_callback_url(a)
#   extra_params[:extra].merge!({ success_url: 1 })
#   return extra_params unless a.nil?
#   extra_params[:extra].merge({ cancel_url: 2})
# end
#
# def upacp_wap_callback_url
#   extra_params.merge({ result_url: params[:callback_url] })
# end
#
# p alipay_wap_callback_url(nil)

class User
  def self.say
    p self.class
  end
end
#
# User.say
require 'digest'
# p Digest::MD5.hexdigest('12')
#
# # @name ||= "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}#{File.extname(original_filename)}"
# p Digest::MD5.hexdigest((Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0'))
# p Digest::MD5.hexdigest("#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}")
# p Time.now.to_i.to_s
#
# p "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
# p "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
# p (Time.now).to_f
# p (Time.now).to_
# ids = [1, 2, 3, 3]
#
# p  ids.uniq
# content = 'HRASF00101'
# REGEXP = /(^[H])([A-Z]*)([0-9]*)/
#
# content.gsub!(REGEXP)
# p content
# a1 = ''
# b1 = ''
# c1 = ''
# content.gsub!(REGEXP) {
#   a1 = $1
#   b1 = $2
#   c1 = $3
# }

# nums = [1, 1, 2, 3, 3, 5]
# p nums.each_with_object(Hash.new(0)) { |e, a| a[e] += 1 }
#
# CHILD_ATTRIBUTES = %i(bdevent_id product_model_ids).freeze
# def child_attributes
#    CHILD_ATTRIBUTES.each_with_object({}) do |key, hash|
#       hash[key] = key
#     end
# end
# p child_attributes


# # Update all billing objects with the 3 different attributes given
# Billing.update_all( "category = 'authorized', approved = 1, author = 'David'" )
#
# # Update records that match our conditions
# Billing.update_all( "author = 'David'", "title LIKE '%Rails%'" )
#
# # Update records that match our conditions but limit it to 5 ordered by date
# Billing.update_all( "author = 'David'", "title LIKE '%Rails%'",
#                     :order => 'created_at', :limit => 5 )
#
# # Updating one record:
# Person.update(15, :user_name => 'Samuel', :group => 'expert')
#
# # Updating multiple records:
# people = { 1 => { "first_name" => "David" }, 2 => { "first_name" => "Jeremy" } }
# Person.update(people.keys, people.values)

#
# The opposite of reject is select
# The opposite of keep_if is delete_if
