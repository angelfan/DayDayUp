class Name
  def get
    class << self
      self
    end
  end
end

class B
  def get
    class << self
      self
    end
  end
end

name = Name.new
p Name.new
p name.get
p B.new.get

p Class

require 'benchmark'
Benchmark.bm do |b|
  name = Name.new
  b.report 'sdfr' do
    name.get
  end
end

module Kernel
  def using(name)
    name.to_s + 'hello'
  end
end

p using('geng')
