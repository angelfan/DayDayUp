class AbstractFactory
  def create_cls(_name)
    fail 'Abstract not access.'
  end
end

class Factory < AbstractFactory
  def create_cls(name)
    # On rails has name.constantize
    eval(name)
  end
end

class AbstractPrdA
  attr_accessor :name

  def initialize(name)
    @name = name || self.class.name
  end
end

class PrdA1 < AbstractPrdA
end

class PrdA2 < AbstractPrdA
end

class AbstractPrdB
  attr_accessor :name
  def initialize(name)
    @name = name || self.class.name
  end
end

class PrdB1 < AbstractPrdB
end

class PrdB2 < AbstractPrdB
end

p Factory.new.create_cls('PrdA1').name
p Factory.new.create_cls('PrdA1.new("abc")').name
