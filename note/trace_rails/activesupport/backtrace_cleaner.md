# ActiveSupport::BacktraceCleaner

```ruby
bc = ActiveSupport::BacktraceCleaner.new

bc.add_filter   { |line| line += 1 }
bc.add_silencer { |line| line == 2 }
bc.clean([1, 2]) # 3
```

Rails::BacktraceCleaner 继承了 ActiveSupport::BacktraceCleaner

# TODO