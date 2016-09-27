require File.dirname(__FILE__) + '/../checkout/order'
require File.dirname(__FILE__) + '/../checkout/coupon'

class OrderBuilder
  attr_reader :order

  def initialize(coupon, items_option)
    @order = Order.new(coupon, items_option)
    @order.price = items_total
    @order.discount = discount
  end

  def coupon
    order.coupon
  end

  def items_total
    @items_total ||= order.items.reduce(0) { |s, i| s += (i.price * i.quantity) }
  end

  def discount
    return 0 unless coupon.rules.all? { |r| r.conformed?(order.to_serial_units) }
    items_total_price = items_total
    coupon.discount_formula.diff(items_total_price)
  end
end

# 固定金额结账
coupon_options = {
  discount_type: 'pay',
  price: 50,
  rules: [['A', 4], ['B', 4]]
}
coupon = Coupon.new(coupon_options)
items_option = [['A', 5, 20], ['B', 11, 30]]
order = OrderBuilder.new(coupon, items_option).order
p order.price
p order.discount

# 折扣固定金额
coupon_options = {
  discount_type: 'fixed',
  price: 50,
  rules: [['A', 4], ['B', 4]]
}
coupon = Coupon.new(coupon_options)
items_option = [['A', 5, 20], ['B', 11, 30], ['C', 11, 30]]
order = OrderBuilder.new(coupon, items_option).order
p order.price
p order.discount

# 百分比折扣
coupon_options = {
  discount_type: 'percentage',
  percentage: 0.5,
  rules: [['A', 4], ['B', 4]]
}
coupon = Coupon.new(coupon_options)
items_option = [['A', 5, 20], ['B', 11, 30]]
order = OrderBuilder.new(coupon, items_option).order
p order.price
p order.discount
