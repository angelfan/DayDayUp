# [ActiveModel::Errors](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/errors.rb)

## Description
[ActiveModel::Validations](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/validations.rb) 主要是依赖它来实现的

## Example
```ruby
class Person
  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  attr_accessor :name
  attr_reader   :errors

  def validate!
    errors.add(:name, :blank, message: "cannot be nil") if name.nil?
  end

  # The following methods are needed to be minimally implemented

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end

#   person = Person.new
#   person.validate!            # => ["cannot be nil"]
#   person.errors.full_messages # => ["name cannot be nil"]
```


## analysis

```ruby
def generate_message(attribute, type = :invalid, options = {})
  type = options.delete(:message) if options[:message].is_a?(Symbol)

  if @base.class.respond_to?(:i18n_scope)
    defaults = @base.class.lookup_ancestors.map do |klass|
      [ :"#{@base.class.i18n_scope}.errors.models.#{klass.model_name.i18n_key}.attributes.#{attribute}.#{type}",
        :"#{@base.class.i18n_scope}.errors.models.#{klass.model_name.i18n_key}.#{type}" ]
    end
  else
    defaults = []
  end

  defaults << :"#{@base.class.i18n_scope}.errors.messages.#{type}" if @base.class.respond_to?(:i18n_scope)
  defaults << :"errors.attributes.#{attribute}.#{type}"
  defaults << :"errors.messages.#{type}"

  defaults.compact!
  defaults.flatten!

  key = defaults.shift
  defaults = options.delete(:message) if options[:message]
  value = (attribute != :base ? @base.send(:read_attribute_for_validation, attribute) : nil)

  options = {
    default: defaults,
    model: @base.model_name.human,
    attribute: @base.class.human_attribute_name(attribute),
    value: value
  }.merge!(options)

  I18n.translate(key, options)
end

# deafult => {:name=>[{:error=>:blank}]}
# messages => {:name=>[{:default=>'cannot be nil', :model=>"Person", :attribute=>:name, :value=>nil}]}
# 如果没有default值, 也就是没有显式传入message: xxx 会i18翻译
# 大概会像这个样
# key => activerecord.attributes.user.name
# defaults => errors.messages.blank
# I18n.translate(key, options)
```

```ruby
# Returns a full message for a given attribute.
#
#   person.errors.full_message(:name, 'is invalid') # => "Name is invalid"
def full_message(attribute, message)
  return message if attribute == :base
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  I18n.t(:"errors.format", {
    default:  "%{attribute} %{message}",
    attribute: attr_name,
    message:   message
  })
end
```