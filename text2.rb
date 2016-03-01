
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




# require 'docx/html'
#
# d = Docx::Document.open('test.docx')
#
# p d.to_html
#
# require 'pandoc-ruby'
# PandocRuby.bin_path='DayDayUp'
#
# @converter = PandocRuby.new('test.docx', :from => :markdown, :to => :rst)
# puts @converter.convert

# @converter = PandocRuby.new('# Markdown Title', :from => :markdown, :to => :rst)
# puts @converter.convert

# hash = {
#     a: 12,
#     b: 112,
#     c: 1234
# }

# a =  hash.inject do |memo, word|
#   # p a += 1
#   # p memo
#   # p word
#   memo.length > word.length ? memo : word
# end
#
# p a

# av = hash.inject({}) do |hash, (key, value)|
#   hash[key] = value.to_f
#   hash
# end
# p av

# require 'tempfile'
#
# tmp = Tempfile.new("tmp")
#
# p tmp.path # => /tmp/tmp20110928-12389-8yyc6w 不唯一
#
# tmp.write("This is a tempfile")
# tmp.rewind
# p tmp.read # => "This is a tempfile"
#
# tmp.close

# NORMALIZE_TABLE = {
#     '0' => 'Left',
#     '1' => 'Center',
#     '2' => 'Right'
# }
#
# p NORMALIZE_TABLE.value?(value)
# def time_to(to_time, from_time = Time.now)
#   multiplies = [
#       [:seconds, 1],
#       [:minutes, 60],
#       [:hours, 60*60],
#       [:days, 60*60*24]
#   # add more if needed
#   ]
#
#   diff = (to_time - from_time).to_i
#
#   raise ArgumentError.new("to_time can not be less than from_time") if diff < 0
#
#   multiplies.inject([:seconds, diff]) { |result, (unit, multiplier)|
#     if diff >= multiplier
#       {unit: unit, count: (diff / multiplier)}
#     else
#       result
#     end
#   }
# end
#
#
# p time_to(Time.new '2106-11-19 09:55:14')
#
# a = {"TWD":"1499.0","USD":"49.95","JPY":"5380.0","HKD":"379.0"}
# a.each do |key, value|
#   a[key] = value.to_f
# end
# p a
#
# require 'openssl'
#
# key = 'UITN25LMUQC436IM'
# def aes128_encrypt(data)
#   cipher = OpenSSL::Cipher::AES.new("128-ECB")
#   cipher.encrypt
#   cipher.key = 'UITN25LMUQC436IM'
#   cipher.update(data)
# end
#
# def aes128_decrypt(data)
#   aes = OpenSSL::Cipher::AES.new("128-ECB")
#   aes.decrypt
#   aes.key = 'UITN25LMUQC436IM'
#   aes.update(data)
# end
#
#
# def encrypted(data)
#   cipher = OpenSSL::Cipher::AES.new(128, :CBC)
#   cipher.encrypt
#   cipher.key = 'UITN25LMUQC436IM'
#   encrypted = cipher.update(data) + cipher.final
# end
#
# def verify(encrypted)
#   decipher = OpenSSL::Cipher::AES.new(128, :CBC)
#   decipher.decrypt
#   decipher.key = 'UITN25LMUQC436IM'
#   plain = decipher.update(encrypted) + decipher.final
# end
#
#
# data = {order_id: 1, remote_id: 24}.to_s


# p "但是asd" =~ /[^\u0000-\u007F]+/
# p "  asd      DFG.," =~ /[^\u0000-\u007F]+/
# p "as但是d" =~ /[^\u0000-\u007F]+/
# p "asd但是" =~ /[^\u0000-\u007F]+/


target1 = [ {material: 'legend', quantity: '5'}, {material: 'angel', quantity: '10'}, {material: 'angel', quantity: '5'} ] # => { legend: 5, angel: 15 }
target2 = [ {material: 'angel', quantity: '15'}, {material: 'legend', quantity: '5'} ]
# target = [  {material: 'legend', quantity: '5'},  {material: 'angel', quantity: '15'}]
# target2 = [ {material: 'angel', quantity: '15'}, {material: 'legend', quantity: '5'} ]
#
# p target == target2
# a = {a:1, b:2, c:3, d: 4 }
# b = {b:2, a:1, d:4, c: '3'.to_i }
# p a == b
# # new = {}
# # from.each do |hash|
# #   if new[hash[:material].to_sym]
# #     new[hash[:material].to_sym] += hash[:quantity].to_i
# #   else
# #     new[hash[:material].to_sym] = hash[:quantity].to_i
# #   end
# # end
# #
# #
# a = from.each_with_object({}) do |value, hash|
#   p hash[value[:material]].to_i
#   hash[value[:material]] ||= 0
#   hash[value[:material]] += value[:quantity].to_i
# end
# p a

# p [ {material: 'legend', quantity: '5'}, {material: 'angel', quantity: '10'}, {material: 'angel', quantity: '5'} ].
#       each_with_object(Hash.new(0)) { |hash, e| hash[e[:material]] += e[:quantity].to_i; hash }

# module Enumerable
#
#   # Generates a hash mapping each unique symbol in the array
#   # to the absolute frequency it appears.
#   #
#   #   [:a,:a,:b,:c,:c,:c].frequency  #=> {:a=>2,:b=>1,:c=>3}
#   #
#   # CREDIT: Brian Schröder
#   #
#   #--
#   # NOTE: So why not use #inject here? e.g. ...
#   #
#   #   inject(Hash.new(0)){|p,v| p[v]+=1; p}
#   #
#   # Because it is a fair bit slower than the traditional definition.
#   #++
#
#   def frequency
#     p = Hash.new(0); each{ |v| p[v] += 1 }; p
#
#   end
#
# end
# p [:a,:a,:b,:c,:c,:c].frequency
#
# ha = [{a: 2, b: 2},{a: 3, b: 3},{a: 4, b: 2}]
# ha.each do |hash|
#   hash.delete(:a)
# end
#
# p ha
# p CGI.escape("https://d2yk122nlepj29.cloudfront.net/uploads/work/print_image/57353/DanKa_\u5c0f\u7d05\u5e3d_0120151126-13650-18wxhem.jpg?v=1448535078")


# def randomString
#   ch = [ '0', '1', '2', '3', '4', '5', '6', '7', '8',
#            '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
#            'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
#            'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
#            'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
#            'z', '0', '1' ]
#   temp = []
#   SecureRandom.hex(3).upcase
# end
#


# puts [*'a'..'z',*'0'..'9',*'A'..'Z'].sample(3).join
# puts ['a'..'z','0'..'9','A'..'Z'].to_a.shuffle(0..3).join



# a = [1, 2, 3]
# p Hash[a.map { |x| [x, true]}]
#
# b = a.reduce({}) do |hash, e|
#   hash.update(e => true)
# end
#
# p b

# target = [{material: 'legend', quantity: '5'}, {material: 'angel', quantity: '10'}, {material: 'angel', quantity: '5'}]
# target.each_with_object(Hash.new(0)) do |value, hash|
#   hash[value[:material]] += value[:quantity].to_i
# end # {"legend"=>5, "angel"=>15}
#
# target = [{material: 'legend', quantity: '5'}, {material: 'angel', quantity: '10'}, {material: 'angel', quantity: '5'}]
# target.reduce(Hash.new(0)) do |hash, value|
#   hash[value[:material]] += value[:quantity].to_i
#   hash
# end # {"legend"=>5, "angel"=>15}
#
#
# [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5].chunk { |n| n.even? }.each { |even, ary| p [even, ary] }

def a
  false
end

def b
  false
end

def c
  true
end

unless b || c || a
  p 'o'
end

# 指定 size 建立空白圖檔
def create_blank_image(width, height, color: 'white', format: 'PNG32')
  tempfile = Tempfile.new(['canvas', '.png'])
  p tempfile
  system "convert -size #{width}x#{height} xc:#{color} #{format}:#{tempfile.path}"
  MiniMagick::Image.open(tempfile.path)
ensure
  tempfile.close
  tempfile.unlink
end

create_blank_image('100', '101')