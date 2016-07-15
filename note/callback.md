# 关于callback

# example
```ruby
class Order < ActiveRecord::Base
  after_create :create_trade, :create_purchase, :notice_some_user

  private
  def create_trade
    posts << Trade.create(default_post_attributes)
  end

  def create_purchase
    posts << Purchase.create(default_post_attributes)
  end

  def notice_some_user
    Notifer.new(some_user).notice
  end
end

class Trade < ActiveRecord::Base
  after_save :create_anoter_record

  private

  def create_anoter_record
     Another.create(attributes)
  end
end

class Purchase < ActiveRecord::Base
  before_save :ensure_some_condition

  private
  def ensure_some_condition
    if condition
      # something
    end
  end
end

```
当代码还很简洁的时候很容易理清整个脉络 但是当代码越来越多 回调越来越多的时候
就很难理清一个订单被创建以后到底会发生多少事情，
尤其是当回调中夹杂着各种各样的控制语句
于是很可能某一天当我们要给创建订单式新增一个系列额特性的时候就会被这些callback搞疯掉

## 解决方案一

```ruby
class Order < ActiveRecord::Base
  after_create :execute_init_service

  private
  def execute_init_service
    InitializeOrderService.new().execute
  end
end

class Trade < ActiveRecord::Base
end

class Purchase < ActiveRecord::Base
end

class InitializeOrderService
  def initialize()
  end

  def execute
    create_trade
    create_purchase
    notice_some_user
    create_anoter_record
    ensure_some_condition
  end

  def create_trade
  end

  def create_purchase
  end

  def notice_some_user
  end

  def create_anoter_record
  end

  def ensure_some_condition
  end
end

```

service会帮你处理掉原本callback需要处理的所有事情
如果觉得逻辑都放在一个service里不够单纯， 可以额外创建更单纯的service
这样再若干时间以偶再回头看代码 就会很清楚一个订单被创建之后到底会发生哪些事情
而且测试也会变得比较单纯
只要好好的测试一下InitializeOrderService这个逻辑就好了

--用订阅发布来解耦