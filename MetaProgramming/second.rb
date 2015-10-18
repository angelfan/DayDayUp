class Rubyist
  def what_does_he_do
    @person = 'A Rubyist'
    'Ruby programming'
  end
end

an_object = Rubyist.new
puts an_object.class # => Rubyist
puts an_object.class.instance_methods(false) # => what_does_he_do
an_object.what_does_he_do
puts an_object.instance_variables # => @person

obj = Object.new
if obj.respond_to?(:program)
  obj.program
else
  puts "Sorry, the object doesn't understand the 'program' message."
end

class Rubyist
  def welcome(*args)
    'Welcome ' + args.join(' ')
  end
end

obj = Rubyist.new
puts(obj.send(:welcome, 'famous', 'Rubyists'))

class Rubyist
  define_method :hello do |my_arg|
    my_arg
  end
end

obj = Rubyist.new
puts(obj.hello('Matz')) # => Matz

class Rubyist
  def method_missing(m, *args, &block)
    puts "Called #{m} with #{args.inspect} and #{block}"
  end
end

Rubyist.new.anything # => Called anything with [] and
Rubyist.new.anything(3, 4) { something } # => Called anything with [3, 4] and #<Proc:0x02efd664@tmp2.rb:7>

class Car
  def go(place)
    puts "go to #{place}"
  end

  def method_missing(name, *args)
    if name.to_s =~ /^go_to_(.*)/
      go(Regexp.last_match(1))
    else
      super
    end
  end
end

car = Car.new
car.go_to_taipei
# go to taipei
car.go_to_shanghai
# go to shanghai
car.go_to_japan
# go to japan

class Rubyist
  def method_missing(m, *args, &block)
    puts "Method Missing: Called #{m} with #{args.inspect} and #{block}"
  end

  def hello
    puts 'Hello from class Rubyist'
  end
end

class IndianRubyist < Rubyist
  def hello
    puts 'Hello from class IndianRubyist'
  end
end

obj = IndianRubyist.new
obj.hello # => Hello from class IndianRubyist

class IndianRubyist
  remove_method :hello # removed from IndianRubyist, but still in Rubyist
end
obj.hello # => Hello from class Rubyist

class IndianRubyist
  undef_method :hello # prevent any calls to 'hello'
end
obj.hello # => Method Missing: Called hello with [] and

class Rubyist
  def initialize
    @geek = 'Matz'
  end
end
obj = Rubyist.new

# instance_eval可以操纵obj的私有方法以及实例变量

obj.instance_eval do
  puts self # => #<Rubyist:0x2ef83d0>
  puts @geek # => Matz
end

class Rubyist
end

# 添加实例方法
Rubyist.class_eval do
  def who
    'Geek'
  end
end
obj = Rubyist.new
puts obj.who # => Geek

# 访问类变量
class Rubyist
  @@geek = "Ruby's Matz"
end

Rubyist.class_variable_set(:@@geek, 'Matz rocks!')
puts Rubyist.class_variable_get(:@@geek) # => Matz rocks!

class Rubyist
  @@geek = "Ruby's Matz"
  @@country = 'USA'
end

class Child < Rubyist
  @@city = 'Nashville'
end
print Rubyist.class_variables # => [:@@geek, :@@country]
puts
p Child.class_variables # => [:@@city]

class Rubyist
  def initialize(p1, p2)
    @geek = p1
    @country = p2
  end
end
obj = Rubyist.new('Matz', 'USA')
puts obj.instance_variables # => Matz
puts obj.instance_variable_get(:@country) # => USA

def foo
  bar = 'baz'
  binding
end

eval('p bar', foo)

def who
  person = 'Matz'
  yield('rocks')
end

person = 'Matsumoto'

who do |y|
  puts("#{person}, #{y} the world") # => Matsumoto, rocks the world
  city = 'Tokyo'
end
