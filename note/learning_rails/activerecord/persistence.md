# ActiveRecord::Persistence
主要负责ActiveRecord的持久化

## save 主要会做两件事情

### AttributeMethods#arel_attributes_with_values_for_update

```ruby
def _read_attribute(attr_name) # :nodoc:
  @attributes.fetch_value(attr_name.to_s) { |n| yield n if block_given? }
end
```
### Relation#_update_record









