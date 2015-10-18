class Gift
  def initialize
    @name = 'book'
    @price = 15.95
  end
end
gift = Gift.new
hash = {}
gift.instance_variables.each { |var| hash[var.to_s.delete('@')] = gift.instance_variable_get(var) }
p hash # => {"name"=>"book", "price"=>15.95}

module ActiveRecordExtension
  def to_hash
    hash = {}; attributes.each { |k, v| hash[k] = v }
    hash
  end
end
class Gift < ActiveRecord::Base
  include ActiveRecordExtension
end
gift.to_hash

# gem hashie
class A
  include Hashable
  attr_accessor :blist
  def initialize
    @blist = [B.new(1), { 'b' => B.new(2) }]
  end
end
class B
  include Hashable
  attr_accessor :id
  def initialize(id)
    @id = id
  end
end
a = A.new
a.to_dh # or a.to_deep_hash
# {:blist=>[{:id=>1}, {"b"=>{:id=>2}}]}
