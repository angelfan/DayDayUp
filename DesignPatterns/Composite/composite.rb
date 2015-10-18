class Component
  attr_reader :component
  attr_accessor :parent

  def initialize
    @parent = nil
    @component = []
  end

  def add(obj)
    @component << obj
    obj.parent = self
  end

  def remove(obj)
    @component.delete(obj)
  end

  def get_child
    @component.count
  end
end

class A < Component
  def initialize
    super
  end
end

class B < Component
  attr_accessor :parent
  def initialize
    super
  end
end

class C
  def initialize
    @name = 1
  end
end

a = A.new
b = B.new
c = C.new

# a.add(b)
# b.add(c)
# p a

a.add(b)

p a.component
p b.parent
