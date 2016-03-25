# 关于取名

## 取名不应该依赖情景

```ruby
# 比如 因为业务需求 A 工厂的商品需要移交给 B 工厂生产
class Product
   def delivering?
     self.state == 'delivering'
   end
end
```

## 取名应该依赖客观事实

```ruby
# 随着业务的发展A工厂的某些商品不需要生产
# 基本逻辑跟之前的业务没有任何差别
# 但是 继续用 delivering就会显得比较奇怪
# 如果一开始就是 waiting_production
# 那么不管是第一个需求 还是第二个需求都用起来都不会觉得奇怪
class Product
   def waiting_production?
     self.state == 'waiting_production'
   end
end
```