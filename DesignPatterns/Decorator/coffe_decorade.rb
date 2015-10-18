# 装饰模式
module Decorator
  def initialize(decorated)
    @decorated = decorated
  end

  def method_missing(method, *args)
    args.empty? ? @decorated.send(method) : @decorated.send(method, args)
  end
end

class Coffee
  def cost
    2
  end
end

class Milk
  include Decorator
  def cost
    @decorated.cost + 0.4
  end
end

class Whip
  include Decorator
  def cost
    @decorated.cost + 0.2
  end
end
class Sprinkles
  include Decorator
  def cost
    @decorated.cost + 0.3
  end
end
p Milk.new(Coffee.new)
p Whip.new(Coffee.new).cost
#=> 2.2
p Sprinkles.new(Whip.new(Milk.new(Coffee.new))).cost
#=> 2.9

# class CoffeeFactory
#   def self.latte
#     SteamedMilk.new(Espresso.new)
#   end
#
#   def self.cappuccino
#     Sprinkles.new(Cream.new(Milk.new(Coffee.new)))
#   end
# end
#
# order = Order.new
# order.add(Coffee.new)
# order.add(CoffeeFactory
#               .cappuccino)
# puts order.total
