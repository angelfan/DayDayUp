# encoding: utf-8

# 有三个角色 （"商品"，"买家"，"卖家"）
# 1.买家关注商品后商品出现价格变动的时候通知该买家
# 2.买家可以设置当某个商品降价到一定程度的时候通知该买家
# 3.卖家可以知道有多少人关注该商品

# 商品显示
# 1.商品涨价和降价前台的显示会发生相应的改变出现："涨" 和 "降"
# 2.商品打八折以上出现"折"
# 3.商品打八折以下出现"促"

module Subject
  def initialize
    @observers = []
  end

  def add_observer(ob)
    @observers << ob unless @observers.include?(ob)
  end

  def delete_observer(ob)
    @observers.delete ob
  end

  # 修改点1， 将发布消息调用的函数通过参数接收过来, 或者通过method_missing
  # 通知设置提醒的买家
  def notify_observer(func)
    @observers.each do |ob|
      ob.send(func, self) if ob.state == 0
    end
  end

  def notify_remind_observer(func)
    @observers.each do |ob|
      ob.send(func, self) if ob.state == 1
    end
  end
end

# 商品类
class Product
  include Subject
  attr_reader :owner, :name, :price, :old_price, :discount

  def initialize(owner, name, price, discount)
    super()
    @owner = owner
    @name = name
    @price = price
    @old_price = ''
    @discount = discount
    @old_discount = ''
  end

  # 价格变动时发出通知:
  def price=(new_price)
    if @price != new_price

      old_price = @price.to_i
      @price = new_price
      @old_price = old_price

      @observers.each do |ob|
        if ob.remind_price >= new_price
          ob.state = 1
          notify_remind_observer(:remind_price_ok)
        end
      end

      if new_price < old_price
        # notify_observers_down_price
        notify_observer(:down_price)
        # 商品降价
      else
        notify_observer(:up_price)
        # 商品涨价
      end

    end
  end

  # 折扣变动时发出通知
  def discount=(new_discount)
    old_discount = @discount
    if new_discount != new_discount
      @discount = new_discount
      notify_observers
      if new_discount >= 8
        # 八折以上
      end
    end
  end
end

# 管理类
module MethodManage
  def down_price(product)
    puts "#{product.owner.name}的#{product.name}提醒您： 商品降价了, 原价是 #{product.old_price}，现价是 #{product.price}"
  end

  def up_price(product)
    puts "#{product.owner.name}的#{product.name}提醒您： 商品涨价了, 原价是 #{product.old_price}，现价是 #{product.price}"
  end

  def discount(product)
    puts "#{product.owner.name}的#{product.name}提醒您： 商品涨价了, 原价是 #{product.old_discount}，现价是 #{product.discount}"
  end

  def remind_price_ok(product)
    puts "#{product.owner.name}的#{product.name}提醒您： 您可以购买#{product.name}了, 现价是 #{product.price}"
  end
end

class Buyers
  include MethodManage
  attr_accessor :name, :remind_price, :state
  def initialize(name)
    @name = name
    @remind_price = -1
    @state = 0
  end

  # 关注商品后，商品价格发生变化通知购买者
  def mark(product)
    @state = 0
    product.add_observer(self)
    add_buyer(product)
  end

  # 设置提醒，当价格到达一定程度通知购买者
  def remind(product, price)
    @state = 2
    @remind_price = price
    product.add_observer(self)
    add_buyer(product)
  end

  private

  def add_buyer(product)
    product.owner.add_buyer(self) unless product.owner.buyers.include?(self)
  end
end

class Sellers
  attr_reader :name, :buyers
  def initialize(name)
    @name = name
    @buyers = []
  end

  def add_buyer(buyer)
    @buyers << buyer
  end
end

seller_jack = Sellers.new('jack')
apple = Product.new(seller_jack, 'Apple', '100', 1)
buyer_angel = Buyers.new('angel')
buyer_angel.mark(apple)
buyer_legend = Buyers.new('legend')
buyer_legend.remind(apple, 40)
apple.price = 101
apple.price = 30
p seller_jack.buyers
