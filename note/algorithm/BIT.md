http://baike.baidu.com/link?url=QNam9pbqmlYKR7dPwbX9Hp_lBjQyCqNay6ug74M-cr36wCtkwAEwI9UrN4PV7XBF8aE3xHkM3J1J86Mixv0_Wq
https://zh.wikipedia.org/wiki/%E6%A0%91%E7%8A%B6%E6%95%B0%E7%BB%84

```ruby
class FenwickTree
  attr_accessor :n, :sums

  def initialize(n)
    @n = n
    @sums = Array.new(n + 1) { 0 }
  end

  def add(x, val)
    while x <= n
      sums[x] += val
      x += lowbit(x)
    end
  end

  def insert(x, y, val)
    add(x, val)
    add(y+1, -val)
  end

  def lowbit(x)
    x & -x
  end

  def sum(x)
    res = 0
    while x > 0
      res += sums[x]
      x -= lowbit(x)
    end
    res
  end

  def query(x, y)
    sum(y) - sum(x-1)
  end
end

ft = FenwickTree.new(5)
[5,2,3,1,1].each do |v|
  ft.add(v, v)
end

p ft.sum(5)
ft.insert(3,5,4)
p ft.query(3,5)
```

树状数组是一个可以很高效的进行区间统计的数据结构。在思想上类似于线段树，比线段树节省空间，编程复杂度比线段树低，但适用范围比线段树小。
