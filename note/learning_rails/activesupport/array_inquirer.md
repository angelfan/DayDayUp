# ActiveSupport::ArrayInquirer

```ruby
variants = ActiveSupport::ArrayInquirer.new([:phone, :tablet])

variants.phone?    # => true
variants.desktop?  # => false
variants.any?(:phone, :tablet)     # => true
variants.any?(:desktop, :watch)    # => false
```

+ 重写any? 他会去call#Array类的#any?
any?{|candidate| include?(candidate.to_sym) || include?(candidate.to_s)}

+ 重写method_missing, call#phone?的时候委托到#any?(:phone)

+ 重写 respond_to_missing?