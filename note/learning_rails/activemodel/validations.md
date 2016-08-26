## analysis

```ruby
# validates_each :first_name, :last_name, allow_blank: true do |record, attr, value|
#   record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
# end

def validates_each(*attr_names, &block)
  validates_with BlockValidator, _merge_attributes(attr_names), &block
end

def validates_with(*args, &block)
  # 关键 _validators[attribute.to_sym] << validator
  options = args.extract_options!
  options[:class] = self

  args.each do |klass|
    validator = klass.new(options, &block)

    if validator.respond_to?(:attributes) && !validator.attributes.empty?
      validator.attributes.each do |attribute|
        _validators[attribute.to_sym] << validator
      end
    else
      _validators[nil] << validator
    end

    validate(validator, options)
  end
end

def validate(*args, &block)
  # set_callback
  options = args.extract_options!

  if args.all? { |arg| arg.is_a?(Symbol) }
    options.each_key do |k|
      unless VALID_OPTIONS_FOR_VALIDATE.include?(k)
        raise ArgumentError.new("Unknown key: #{k.inspect}. Valid keys are: #{VALID_OPTIONS_FOR_VALIDATE.map(&:inspect).join(', ')}. Perhaps you meant to call `validates` instead of `validate`?")
      end
    end
  end

  if options.key?(:on)
    options = options.dup
    options[:if] = Array(options[:if])
    options[:if].unshift ->(o) {
      !(Array(options[:on]) & Array(o.validation_context)).empty?
    }
  end

  args << options
  set_callback(:validate, *args, &block)
end
```

```ruby
def valid?(context = nil)
  current_context, self.validation_context = validation_context, context
  errors.clear
  run_validations!
ensure
  self.validation_context = current_context
end
```

调用valid?的时候会run_validations!
把之前的回调执行一遍
