FooError = Class.new(StandardError)

def some_method
  body
end

def no_op; end

# 空格提高可读性
sum = 1 + 2
a = 1
b = 2
1 > 2 ? true : false; puts 'Hi'
[1, 2, 3].each { |e| puts e }

# 指数操作是例外
e = M * c**2

# 好——`{` 之后和 `}` 之前有空格
{ one: 1, two: 2 }

# 好——`{` 之后和 `}` 之前没有空格
{ one: 1, two: 2 }

# ( 、 [ 之后， ] 、 ) 之前，不要有空格。
some(arg).other
[1, 2, 3].length

# ! 后不要有空格。
# 好
!something

# 范围表达式中间不要有空格。
# 好
1..3
'a'...'z'

# 好
case
when song.name == 'Misty'
  puts 'Not again!'
when song.duration > 120
  puts 'Too long!'
when Time.now.hour > 21
  puts "It's too late"
else
  song.play
end

# 好 - 结构很清晰
kind = case year
       when 1850..1889 then 'Blues'
       when 1890..1909 then 'Ragtime'
       when 1910..1929 then 'New Orleans Jazz'
       when 1930..1939 then 'Swing'
       when 1940..1950 then 'Bebop'
       else 'Jazz'
       end

result = if some_cond
           calc_something
         else
           calc_something_else
         end

# 好
def send_mail(source)
  Mailer.deliver(to: 'bob@example.com',
                 from: 'us@example.com',
                 subject: 'Important message',
                 body: source.text)
end

# 差 - 未对齐
menu_item = ['Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam',
             'Baked beans', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam']

# 好
menu_item = [
  'Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam',
  'Baked beans', 'Spam', 'Spam', 'Spam', 'Spam', 'Spam'
]

# 差 - 有几个零？
num = 1_000_000

# 好 - 更容易被人脑解析。
num = 1_000_000

# 好
result = if condition
           x
         else
           y
         end

# 单行主体用 if/unless 修饰符。另一个好的方法是使用 &&/|| 控制流程。

# 差
do_something if some_condition

# 好
do_something if some_condition

# 另一个好方法
some_condition && do_something

# 差
names.map(&:upcase)

# 好
names.map(&:upcase)

# 如果变量未被初始化过，用 ||= 来初始化变量并赋值。
# 差
name = name ? name : 'Bozhidar'

# 差
name = 'Bozhidar' unless name

# 好 仅在 name 为 nil 或 false 时，把名字设为 Bozhidar。
name ||= 'Bozhidar'

# 不要使用 ||= 来初始化布尔变量
enabled = true if enabled.nil?

# 好
l = ->(a, b) { a + b }
l.call(1, 2)

l = lambda do |a, b|
  tmp = a * 7
  tmp * b / 50
end

# 未使用的区块参数和局部变量使用 _ 前缀或直接使用 _

# 当处理你希望将变量作为数组使用，但不确定它是不是数组时， 使用 [*var] 或 Array() 而不是显式的 Array 检查。
Array(paths).each { |path| do_something(path) }

# 尽量使用范围或 Comparable#between? 来替换复杂的逻辑比较。

# 差
do_something if x >= 1000 && x < 2000

# 好
do_something if (1000...2000).include?(x)

# 好
do_something if x.between?(1000, 2000)

# 避免使用嵌套的条件来控制流程。 当你可能断言不合法的数据，使用一个防御从句。一个防御从句是一个在函数顶部的条件声明，这样如果数据不合法就能尽快的跳出函数。

# 差
def compute_thing(thing)
  if thing[:foo]
    update_with_bar(thing)
    if thing[:foo][:bar]
      partial_compute(thing)
    else
      re_compute(thing)
    end
  end
end

# 好
def compute_thing1(thing)
  return unless thing[:foo]
  update_with_bar(thing[:foo])
  return re_compute(thing) unless thing[:foo][:bar]
  partial_compute(thing)
end

# 差
[0, 1, 2, 3].each do |item|
  puts item if item > 1
end

# 好
[0, 1, 2, 3].each do |item|
  next unless item > 1
  puts item
end

# 使用 TODO: 标记以后应加入的特征与功能。
# 使用 FIXME: 标记需要修复的代码。
# 使用 OPTIMIZE: 标记可能影响性能的缓慢或效率低下的代码。
# 使用 HACK: 标记代码异味，即那些应该被重构的可疑编码习惯。
# 使用 REVIEW: 标记需要确认其编码意图是否正确的代码。举例来说：REVIEW: 我们确定用户现在是这么做的吗？

class Person
  # 首先是 extend 与 include
  extend SomeModule
  include AnotherModule

  # 接着是常量
  SOME_CONSTANT = 20

  # 接下来是属性宏
  attr_reader :name

  # 跟着是其它的宏（如果有的话）
  validates :name

  # 公开的类别方法接在下一行
  def self.some_method
  end

  # 初始化方法在类方法和实例方法之间
  def initialize
  end

  # 跟着是公开的实例方法
  def some_method
  end

  # 受保护及私有的方法，一起放在接近结尾的地方

  protected

  def some_protected_method
  end

  private

  def some_private_method
  end
end

# 如果某个类需要多行代码，则不要嵌套在其它类中。应将其独立写在文件中，存放以包含它的类的的名字命名的文件夹中。
# 差

# foo.rb
class Foo
  class Bar
    # 30个方法
  end

  class Car
    # 20个方法
  end

  # 30个方法
end

# 好

# foo.rb
class Foo
  # 30个方法
end

# foo/bar.rb
class Foo
  class Bar
    # 30个方法
  end
end

# foo/car.rb
class Foo
  class Car
    # 20个方法
  end
end

module SomeClass
  module_function

  def some_method
    # 省略函数体
  end

  def some_other_method
  end
end

# 差
STATES = [:draft, :open, :closed]

# 好
STATES = %i(draft open closed)

# 在处理应该存在的哈希键时，使用 Hash#fetch。
heroes = { batman: 'Bruce Wayne', superman: 'Clark Kent' }
# 差 - 如果我们打错字的话，我们就无法找到对的英雄了
heroes[:batman] # => "Bruce Wayne"
heroes[:supermen] # => nil

# 好 - fetch 会抛出一个 KeyError 来使这个问题明显
heroes.fetch(:supermen)

batman = { name: 'Bruce Wayne', is_evil: false }

# 差 - 如果我们仅仅使用 || 操作符，那么当值为假时，我们不会得到预期的结果
batman[:is_evil] || true # => true

# 好 - fetch 在遇到假值时依然正确
batman.fetch(:is_evil, true) # => false

# 好 - 区块是惰性求职，只有当 KeyError 异常时才执行
batman.fetch(:powers) { obtain_batman_powers }

# 当需要从哈希中同时获取多个键值时，使用 Hash#values_at。

# 差
email = data['email']
username = data['nickname']

# 好
email, username = data.values_at('email', 'nickname')

# 字符串插值不要用 Object#to_s 。Ruby 默认会调用该方法。

# 差
message = "This is the #{result}."

# 好
message = "This is the #{result}."

# 当你可以选择更快速、更专门的替代方法时，不要使用 String#gsub。

url = 'http://example.com'
str = 'lisp-case-rules'

# 差
url.gsub('http://', 'https://')
str.tr('-', '_')

# 好
url.sub('http://', 'https://')
str.tr('-', '_')

# 如果你真的需要“全局”方法，把它们加到 Kernel 并设为私有的。

# 使用模块变量代替全局变量。

# 差
$foo_bar = 1

# 好
module Foo
  class << self
    attr_accessor :bar
  end
end

Foo.bar = 1
