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