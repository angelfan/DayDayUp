# update_all
```ruby
# Overwrite all values in the hstore
MyModel.update_all("hstore_column = hstore('key', 'value')")

# Merge in new attributes:
MyModel.update_all("hstore_column = hstore_column || hstore('key', 'value')")
```

# ransack 支援json字段检索

## 支援json字段
```ruby
ransacker :json_key do |parent|
    Arel.sql "(#{parent.table.name}.json_column->>'json_key')"
end
```

## 支援hstore
```ruby
ransacker :hstore_key do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:hstore_column], 'hstore_key')
end

```

