```ruby
# slow
object.relation.select { |r| %w(state1 state2).include?(r.state) }.size
```

```ruby
# better
object.relation.pluck(:state).select { |state| %w(state1 state2).include?(state) }.size
# or
o.print_items.pluck(:aasm_state).count { |state| %w(state1 state2).include?(state) }
```