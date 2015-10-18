class SimpleLogger
  @@instance = SimpleLogger.new

  def self.get_instance
    @@instance
  end

  private_class_method :new
end

sl1 = SimpleLogger.get_instance
sl2 = SimpleLogger.get_instance
puts sl1 == sl2

# 结果为：true
# 采用一个类变量来保存仅有的一个类的实例，同时需要一个类方法返回这个单例实例

# 但是通过SimpleLogger.new还是可以创建另一个实例对象，因此需要把着个new方法设为私有的
sl3 = SimpleLogger.new
