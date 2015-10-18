# coding: utf-8
class IsNonEmpty
  def self.check(data)
    data.nil?
  end

  def self.notice
    "传入的值不能为空\n"
  end
end

class IsAlphaNum
  def self.check(data)
    data =~ /[^a-z0-9]/
  end

  def self.notice
    "传入的值只能保护字母和数字，不能包含特殊字符\n"
  end
end

class Validate
  attr_reader :msg

  def initialize
    @types = []
    @msg = ''
    @config = {}
  end

  def add_types(type)
    @types << type
  end

  def check(hash_data)
    hash_data.each_pair do |key, val|
      @msg << "#{key}errors #{val[:type].notice}" if val[:type].check(val[:data])
    end
  end

  def errors
    !@msg.nil?
  end
end

validate = Validate.new

hash_data = {
  first: { type: IsNonEmpty, data: 1324 },
  second: { type: IsNonEmpty, data: nil },
  third: { type: IsAlphaNum, data: '123angel' },
  forth: { type: IsAlphaNum, data: '123sf@/!' }
}

validate.check(hash_data)
puts validate.msg if validate.errors
