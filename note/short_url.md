# Short Url

## 第一种方法
给每一个过来的长地址，发一个号即可，小型系统直接用mysql的自增索引就搞定了。
第一个使用这个服务的人得到的短地址是http://xx.xx/0
第二个是 http://xx.xx/1 第11个是 http://xx.xx/a
第依次往后，相当于实现了一个62进制的自增字段即可。

```ruby
class ShortUrl
  def generate
    to_62 Record.create.id
  end

  def to_62(fixnum)
    arr = (0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a
    result = ''
    loop do
      temp = fixnum / 62
      index = fixnum % 62
      fixnum = temp
      result += arr[index].to_s
      break if fixnum == 0
    end
    result.reverse
  end
end
```
问题
1. 没法发保证URL的一一对应习性, 解决办法 可以是查看DB是否存在 或者只是保证近期连接的一一对应性
2. 如果多个节点可以实现多个发号器 比如10个节点 每个节点的尾号为0-9
3。 跳转选择301

## 第二种方法
TODO