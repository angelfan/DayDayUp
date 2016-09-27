class SerialUnit
  attr_reader :item

  def initialize(item, serial_number)
    @item = item
    @serial_number = serial_number
  end

  def name
    item.name
  end
end

class Order
  attr_reader :coupon, :items
  attr_accessor :price, :discount

  def initialize(coupon, items)
    @coupon = coupon
    @items = items.map{|name, quantity, price| OrderItem.new(name, quantity, price)}
  end

  def to_serial_units
    items.map do |item|
      item.quantity.times.to_a.map { |n| SerialUnit.new(item, n.succ) }
    end.flatten
  end
end

class OrderItem
  attr_reader :name, :quantity, :price

  def initialize(name, quantity, price)
    @name = name
    @quantity = quantity
    @price = price
  end
end

