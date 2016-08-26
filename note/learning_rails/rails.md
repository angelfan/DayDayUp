## attribute_method
类似的给一些列属性增加一个共同方法的情况
基本上都是给这种做法
1. define_attribute_methods :name, 声明nama将会需要某些方法
2. attribute_method_prefix 'clear_' 声明这个方法是以clear_——开头的
3. clear_attribute， 将clear_name委托到clear_attribute
```ruby
class Person
  include ActiveModel::AttributeMethods

  attr_accessor :name
  attribute_method_prefix 'clear_'
  define_attribute_methods :name

  private

  def clear_attribute(attr)
    send("#{attr}=", nil)
  end
end
```
### 看rails之前
define_attribute_methods :name 将参数存到类级别的属性上
attribute_method_prefix 声明将会有clear_
调用clear_name的时候通过前面两个条件来决定是否可以将name代理到clear_attribute

### rails的做法
```ruby
class AttributeMethodMatcher
  attr_reader :prefix, :suffix, :method_missing_target

  AttributeMethodMatch = Struct.new(:target, :attr_name, :method_name)

  def initialize(options = {})
    @prefix, @suffix = options.fetch(:prefix, ''), options.fetch(:suffix, '')
    @regex = /^(?:#{Regexp.escape(@prefix)})(.*)(?:#{Regexp.escape(@suffix)})$/
    @method_missing_target = "#{@prefix}attribute#{@suffix}" # 需要委托的方法
    @method_name = "#{prefix}%s#{suffix}"
  end

  def match(method_name)
    if @regex =~ method_name
      AttributeMethodMatch.new(method_missing_target, $1, method_name)
    end
  end

  def method_name(attr_name)
    @method_name % attr_name
  end

  def plain?
    prefix.empty? && suffix.empty?
  end
end
```
作用是通过词缀来匹配方法
```ruby
matcher = AttributeMethodMatcher.new(prefix: 'clear_', suffix: '_default')
p matcher.match('clear_attr_default')
```

### remove_method
remove from child, still in parent
### undef_method
prevent any calls to 'hello'