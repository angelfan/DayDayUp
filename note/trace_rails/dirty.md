# activemodel/lib/active_model/dirty.rb

## Description
被 ActiveRecord::AttributeMethods封装成 ActiveRecord的Dirty

## Example
```ruby
class Person
  include ActiveModel::Dirty

  define_attribute_methods :name

  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def name=(val)
    name_will_change! unless val == @name
    @name = val
  end

  def save
    # do persistence work

    changes_applied
  end

  def reload!
    # get the values from the persistence layer

    clear_changes_information
  end

  def rollback!
    restore_attributes
  end
end
# A newly instantiated +Person+ object is unchanged:
#
#   person = Person.new("Uncle Bob")
#   person.changed? # => false
#
# Change the name:
#
#   person.name = 'Bob'
#   person.changed?       # => true
#   person.name_changed?  # => true
#   person.name_changed?(from: "Uncle Bob", to: "Bob") # => true
#   person.name_was       # => "Uncle Bob"
#   person.name_change    # => ["Uncle Bob", "Bob"]
#   person.name = 'Bill'
#   person.name_change    # => ["Uncle Bob", "Bill"]
#
# Save the changes:
#
#   person.save
#   person.changed?      # => false
#   person.name_changed? # => false
#
# Reset the changes:
#
#   person.previous_changes         # => {"name" => ["Uncle Bob", "Bill"]}
#   person.name_previously_changed? # => true
#   person.name_previous_change     # => ["Uncle Bob", "Bill"]
#   person.reload!
#   person.previous_changes         # => {}
#
# Rollback the changes:
#
#   person.name = "Uncle Bob"
#   person.rollback!
#   person.name          # => "Bill"
#   person.name_changed? # => false
#
# Assigning the same value leaves the attribute unchanged:
#
#   person.name = 'Bill'
#   person.name_changed? # => false
#   person.name_change   # => nil
#
# Which attributes have changed?
#
#   person.name = 'Bob'
#   person.changed # => ["name"]
#   person.changes # => {"name" => ["Bill", "Bob"]}
```

## analysis
主思路就是 将每一次赋值塞进changed_attributes
然后 通过ActiveModel::AttributeMethods 来动态调用方法 去取changed_attributes
### attribute_will_change 会将属性值塞进changed_attributes {attr: value}
```ruby
def attribute_will_change!(attr)
  return if attribute_changed?(attr)

  begin
    value = __send__(attr)
    value = value.duplicable? ? value.clone : value
  rescue TypeError, NoMethodError
  end

  set_attribute_was(attr, value)
end
```

### changes_applied 会将值保存到 previously_changed 然后初始化changed_attributes
```ruby
def changes_applied # :doc:
  @previously_changed = changes
  @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
end
```