# 对象的方法即为其所属类的实例方法
1.methods == 1.class.instance_methods
#=> true

# 类的“溯源”
N = Class.new
N.ancestors
#=> [N, Object, Kernel, BasicObject]
N.class
#=> Class
N.superclass
#=> Object
N.superclass.superclass
#=> BasicObject
N.superclass.superclass.superclass
#=> nil

class Rectangle
  def initialize(*args)
    if args.size < 2 || args.size > 3
      puts 'Sorry. This method takes either 2 or 3 arguments.'
    else
      puts 'Correct number of arguments.'
    end
  end
end

Rectangle.new([10, 23], 4, 10)
Rectangle.new([10, 23], [14, 13])

# 1
class Rubyist
  def self.who
    'Geek'
  end
end

# 2
class Rubyist
  class << self
    def who
      'Geek'
    end
  end
end

# 3
class Rubyist
end
def Rubyist.who
  'Geek'
end

# 4
class Rubyist
end
Rubyist.instance_eval do
  def who
    'Geek'
  end
end

# 5
class << Rubyist
  def who
    'Geek'
  end
end

puts Rubyist.who # => Geek
