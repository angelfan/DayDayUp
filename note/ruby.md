## instance_exec
```ruby
a = Proc.new { |a| a + 2 }
b = Proc.new { instance_exec(1, &a) }
a.call(1) # 3
b.call    # 3
```
