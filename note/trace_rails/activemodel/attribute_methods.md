# [ActiveModel::AttributeMethods](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/attribute_methods.rb)

## Description
[ActiveModel::Dirty](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/dirty.rb) 主要是依赖它来实现的

## Example
```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_affix  prefix: 'reset_', suffix: '_to_default!'
  attribute_method_suffix '_contrived?'
  attribute_method_prefix 'clear_'
  define_attribute_methods :name

  attr_accessor :name

  def attributes
    { 'name' => @name }
  end

  private

  def attribute_contrived?(attr)
    true
  end

  def clear_attribute(attr)
    send("#{attr}=", nil)
  end

  def reset_attribute_to_default!(attr)
    send("#{attr}=", 'Default Name')
  end
end

#   person = Person.new
#   person.name = 'Bob'
#   person.name          # => "Bob"
#   person.clear_name
#   person.name          # => nil
```


## analysis

### define_attribute_method 整理相应的参数 传递给 #define_proxy_call
```ruby
def define_attribute_method(attr_name)
  attribute_method_matchers.each do |matcher|
    method_name = matcher.method_name(attr_name)

    unless instance_method_already_implemented?(method_name)
      generate_method = "define_method_#{matcher.method_missing_target}"

      if respond_to?(generate_method, true)
        send(generate_method, attr_name)
      else
        define_proxy_call true, generated_attribute_methods, method_name, matcher.method_missing_target, attr_name.to_s
      end
    end
  end
  attribute_method_matchers_cache.clear
end
```

### define_proxy_call

```ruby
# 整理出来 有一种会像这样
# Example:
# def prefix_attr_suffix(*args)
#   send(:prefix_attribute_suffix, 'attr')
# end

# 这样 person.clear_name 实际上是 person.send(:clear_attribute, 'name')
def define_proxy_call(include_private, mod, name, send, *extra) #:nodoc:
  defn = if name =~ NAME_COMPILABLE_REGEXP
    "def #{name}(*args)"
  else
    "define_method(:'#{name}') do |*args|"
  end

  extra = (extra.map!(&:inspect) << "*args").join(", ".freeze)

  target = if send =~ CALL_COMPILABLE_REGEXP
    "#{"self." unless include_private}#{send}(#{extra})"
  else
    "send(:'#{send}', #{extra})"
  end

  mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
    #{defn}
      #{target}
    end
  RUBY
end
```