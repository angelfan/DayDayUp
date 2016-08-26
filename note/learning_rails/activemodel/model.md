# ActiveModel::Model

## Description
主要就是靠attribute_assignment来实现
可以用它来实现Form Object

## Example

```ruby
class Person
  include ActiveModel::Model
  attr_accessor :name, :age
end

# person = Person.new(name: 'bob', age: '18')
# person.name # => "bob"
# person.age  # => "18"
```

## analysis

```ruby
def initialize(attributes={})
  assign_attributes(attributes) if attributes

  super()
end
```