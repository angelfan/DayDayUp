# autoload


## ruby autoload

```ruby
class RubyAuto
  autoload :MyModule, File.dirname(__FILE__) + '/my_module'

  def load
    MyModule
  end
end


defined? MyModule # nil
RubyAuto.new.load
defined? MyModule # "constant"
```

## active support autoload
对ruby autoload做了一些包装
```ruby
def autoload(const_name, path = @_at_path)
  unless path
    full = [name, @_under_path, const_name.to_s].compact.join("::")
    path = Inflector.underscore(full)
  end

  if @_eager_autoload
    @_autoloads[const_name] = path
  end

  super const_name, path
end

def eager_load!
  @_autoloads.each_value { |file| require file }
end
```

```ruby
require 'active_support/all'

class ASAuto
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :MyModule, File.dirname(__FILE__) + '/my_module'
  end
end

ASAuto.eager_load!
defined? MyModule # "constant"
```

