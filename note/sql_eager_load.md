```ruby
class Order < ActiveRecord::Base
    has_many :order_items
end

class OrderItem < ActiveRecord::Base
    belongs_to :order
end
```

## preload
```ruby
Order.preload(:order_items).where(id: 1)
# 总是生成链条sql
# 并且无法使用 order_items表
Order.preload(:order_items).where('order_items.id': 1)
```

## includes
比preload聪明一些 可以使用order_items表
```ruby
# 可以通过references编程一条查询
Order.includes(:order_items).where(id: 1).references(:order_items)
```

## eager_load
LEFT OUTER JOIN 一条查询
```ruby
Order.eager_load(:order_items).where(id: 2)
```

## joins
INNER JOIN 来加载关联数据
1. 不会查村树关联的数据
2. 可能会差存储重复的结果(当某一个order下面有多个order_items符合检索条件的时候)
```ruby
# 查询数量
Order.joins(:order_items).where('order_items.xx = ?', 'xx').distinct.size
Order.joins(:order_items).where('order_items.xx = ?', 'xx').distinct.count(:attribute)
Order.joins(:order_items).where('order_items.xx = ?', 'xx').select('distinct orders.id').to_a

# 获得uniq objects
Order.joins(:order_items).where('order_items.xx = ?', 'xx').group('orders.id').to_a
Order.joins(:order_items).where('order_items.xx = ?', 'xx').select('distinct orders.*')
Order.joins(:order_items).where('order_items.xx = ?', 'xx').uniq
# 后面两种在有Jons字段的时候不好使会 `could not identify an equality operator for type json`
```

```ruby
orders = Order.joins(:order_items).where('order_items.aasm_state = ?', 'pending').includes(:order_items)
Order.joins(:order_items).where('order_items.aasm_state = ?', 'pending').preload(:order_items)

```