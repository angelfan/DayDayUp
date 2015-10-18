# encoding: utf-8

# 有三个角色 （"商品"，"买家"，"卖家"）
# 1.买家关注商品后商品出现价格变动的时候通知该买家
# 2.买家可以设置当某个商品降价到一定程度的时候通知该买家
# 3.卖家可以知道有多少人关注该商品

# 通过数据库的实现方式
# 1.新建五张张表，商品表，买家表(Buyers)，卖家表，订阅发布表（Sub_pubs），消息表(Messages)（买家表和卖家表合意用一张用户表）
# 2.当买家关注一个商品的时候向订阅发布表中写数据：（加入resource字段可以更好的适应可能出现的新的需求，例如：买家关注卖家后，买家可以得知卖家的一切动态等等）
# {:pub_resource => 'product',
#  :publisher_id => product.id,
#  :sub_resource => 'buyer',
#  :subscriber_id => buyer.id,
#  :action => func}
# 3.当商品价格变动后通过订阅发布表想消息表中写数据：
# {:user_id => buyer.id,
#  :message => 'some text'
#  :state => 0}

# 'notify_observer'将类似于这样
def notify_observer # 不考虑高并发的情况
  Sub_pubs.where(id: self.id).each do |sub_pub|
    some_text = sub_pub.pub_resource.send(sub_pub.action, self)
    Message.create!(user_id: sub_pub.subscriber_id,
                    message: some_text.to_s,
                    state: 0)
  end
end


module Subject
  def initialize
    @observers = []
  end

  def add_observer ob
    unless @observers.include?(ob)
      @observers << ob
    end
  end

  def delete_observer ob
    @observers.delete ob
  end

  # 修改点1， 将发布消息调用的函数通过参数接收过来, 或者通过method_missing
  # 通知设置提醒的买家
  def notify_observer(func)
    @observers.each do |ob|
      if ob.state == 0
        ob.send(func, self)
      end
    end
  end

  def notify_remind_observer(func)
    @observers.each do |ob|
      if ob.state == 1
        ob.send(func, self)
      end
    end
  end

end

# 商品类
class Product
  include Subject
  attr_reader :owner, :name, :price, :old_price

  def initialize(owner, name, price, discount)
    super()
    @owner = owner
    @name = name
    @price = price
    @old_price = ''
  end

  # 价格变动时发出通知:
  def price= new_price
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
  def discount= new_discount
    old_discount = @discount
    if new_discount != new_discount
      @discount = new_discount
      notify_observers
      if new_discount >= 8
        # 八折以上
      else
        # 八折以下
      end
    end
  end
end

# 管理类
module MethodManage
  def down_price product
    puts "#{product.owner.name}的#{product.name}提醒您： 商品降价了, 原价是 #{product.old_price}，现价是 #{product.price}"
  end

  def up_price product
    puts "#{product.owner.name}的#{product.name}提醒您： 商品涨价了, 原价是 #{product.old_price}，现价是 #{product.price}"
  end

  def remind_price_ok product
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
  def mark(resource)
    @state = 0
    resource.add_observer(self)
    add_buyer(resource)
  end

  # 设置提醒，当价格到达一定程度通知购买者
  def remind(resource, price)
    @state = 2
    @remind_price = price
    resource.add_observer(self)
    add_buyer(resource)
  end

  private
  def add_buyer(product)
    unless product.owner.buyers.include?(self)
      product.owner.add_buyer(self)
    end
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

seller_jack = Sellers.new("jack")
apple = Product.new(seller_jack, 'Apple', '100', 1)
buyer_angel = Buyers.new('angel')
buyer_angel.mark(apple)
buyer_legend = Buyers.new('legend')
buyer_legend.remind(apple, 40)
apple.price = 101
apple.price = 30
p seller_jack.buyers

