require 'singleton'
class SimpleLogger
  include Singleton
end

# puts SimpleLogger.new
sl1 = SimpleLogger.instance
sl2 = SimpleLogger.instance
puts sl1 == sl2

# 结果为：true

# ruby类库中提供了singleton，来简化单例类的创建
# 混入Singleton，就省略了创建类变量，初始化单例实例，创建类级别的instance方法，以及将new设为私有
# 通过SimpleLogger.instance来获取日志器的单例

# 但是两种方式还是又差异的
# 第一种方式称之为“勤性单例(eager instantiation)”
# 在确实需要之前就创建了实例对象
# 第二种方式称之为“惰性单例(lazy instantiation)”
# 在调用instance时才会去创建

# 但是这个Singleton不能真正的阻止任何事情，可以用过public_class_method改变new方法的为公用的
# 打开类，设置new方法为public之后，就可以用SimpleLogger.new来创建对象了
class SimpleLogger
  public_class_method :new
end

puts SimpleLogger.new
