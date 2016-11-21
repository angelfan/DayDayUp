# Module Summary

## module可以这么用

```ruby
class ModuleClass < Module
  def dynamic_method(method_name)
    define_method(method_name) { p method_name }
    send(:public, method_name)
  end
end

class Other
  @module_class = ModuleClass.new
  include @module_class
  # include instance_variable_set('@module_class', ModuleClass.new) # 等同于这种写法

  def self.module_class
    @module_class
  end

  def module_class
    self.class.module_class
  end
end

Other.new.module_class.dynamic_method(:hello)
Other.new.hello
```

## get extended modules
```ruby
class Module
  # Return any modules we +extend+
  def extended_modules
    (class << self; self end).included_modules
  end
end
p SomeClass.extended_modules
# Or
p SomeClass.singleton_class.included_modules
```

## get included modules
```ruby
p SomeClass.included_modules
```

## ancestors
在class中 只有被include进来的module才算是ancestor


## 通过prepend module来重写其他module动态定义的方法
```ruby
module Awesome
 def attribute(name)
   define_method("#{name}=") do |val|
     instance_variable_set("@#{name}", "Awesome #{val}")
   end
   attr_reader(name)
 end
end

class Foo
 extend Awesome
 attribute :awesome
end
```
在这种情况下是没办法通过重写awesome来做strip处理的
```ruby
def awesome=(val)
  super(val.strip)
end
```
可以这样处理
```ruby
# ancestors => #<Module:0x007fe1bf09ecc0>, Foo, ...
class Foo
  extend Awesome
  attribute :awesome

  # ruby中方法寻找是按照祖先连的顺序即#ancestors出现的先后顺序一层层的像上面找
  # ancestors中包含Foo本身
  # 通过prepend将module塞入ancestors的最底层
  # 这样module实质上是重写了Foo#awesome=
  # 这里的关键是prepend
  prepend(Module.new do
            def awesome=(val)
              super(val.strip)
            end
          end)
  
end
```

### 或者可以用匿名module来修改Awesome
```ruby
# 作用和上面的刚好相反
# 其本质是在Foo之上增加一个Module
# 该module实现了#awesome=
# ancestors => Foo, #<Module:0x007fe1bf09ecc0>, ...
module Awesome
  def awesome_module
    # 其本质相当于Foo include m
    @awesome_module ||= Module.new().tap { |m| include(m) }
  end

  def attribute(name)
    awesome_module.send(:define_method, "#{name}=") do |val|
      instance_variable_set("@#{name}", "Awesome #{val}")
    end
    awesome_module.send(:attr_reader, name)
  end
end

class Foo
  extend Awesome
  attribute :awesome

  def awesome=(val)
    super(val.strip)
  end
end
```


