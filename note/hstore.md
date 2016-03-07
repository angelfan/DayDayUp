# update
```ruby
# Overwrite all values in the hstore
MyModel.update_all("hstore_column = hstore('key', 'value')")

# Merge in new attributes:
MyModel.update_all("hstore_column = hstore_column || hstore('key', 'value')")
```
