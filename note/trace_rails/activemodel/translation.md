# ActiveModel::Translation

## Description

## Example

```ruby
class TranslatedPerson
  extend ActiveModel::Translation
end

#  TranslatedPerson.human_attribute_name('my_attribute') => "My attribute"
```

## analysis

```ruby
def human_attribute_name(attribute, options = {})
  options   = { count: 1 }.merge!(options)
  parts     = attribute.to_s.split(".")
  attribute = parts.pop
  namespace = parts.join("/") unless parts.empty?
  attributes_scope = "#{self.i18n_scope}.attributes"

  if namespace
    defaults = lookup_ancestors.map do |klass|
      :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.#{attribute}"
    end
    defaults << :"#{attributes_scope}.#{namespace}.#{attribute}"
  else
    defaults = lookup_ancestors.map do |klass|
      :"#{attributes_scope}.#{klass.model_name.i18n_key}.#{attribute}"
    end
  end

  defaults << :"attributes.#{attribute}"
  defaults << options.delete(:default) if options[:default]
  defaults << attribute.humanize

  options[:default] = defaults
  I18n.translate(defaults.shift, options)
end
```