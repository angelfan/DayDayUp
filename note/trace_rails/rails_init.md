# railties

## railties/exe/rails
通过cli让我们可以使用rails提供相关的命令

## railties/lib/rails/commands.rb
可以了解到 `rails s` 实际上是执行了
railties/lib/rails/commands/commands_tasks.rb#server

```
module Rails
  class Server < ::Rack::Server
  end
end
```

所以我们的rails项目中会有一个config.ru
最简单的rack app config.ru 文件 可以这样
```ruby
# config.ru
class MyApp
  def initialize
    super
  end

  def call(_env)
    [200, { 'Content-Type' => 'text/plain' }, ['worked, you are not firefox']]
  end
end

run MyApp.new
```

反观我们的config.ru
```ruby
run Rails.application
```

```ruby
# lib/rails.rb
module Rails
  class << self
    @application = @app_class = nil
    attr_writer :application
    attr_accessor :app_class

    def application
      @application ||= (app_class.instance if app_class)
    end
  end
end
```

app_class从来哪里来？
```ruby
# lib/rails/application.rb
module Rails
  class Application < Engine
    class << self
      def inherited(base)
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end
  end
end
```

反观我们的application.rb
```ruby
module MyApp
  class Application < Rails::Application
  end
end
```

因此 `run Rails.application` 等于 `run MyApp::Application.instance`

## engine

```ruby
class Application < Engine

  def app
    @app || @app_build_lock.synchronize {
      @app ||= begin
        stack = default_middleware_stack
        config.middleware = build_middleware.merge_into(stack)
        config.middleware.build(endpoint)
      end
    }
  end

 def call(env)
    req = build_request env
    app.call req.env
  end


  def routes
    @routes ||= ActionDispatch::Routing::RouteSet.new_with_config(config)
    @routes.append(&Proc.new) if block_given?
    @routes
  end

  def build_request(env)
    env.merge!(env_config)
    req = ActionDispatch::Request.new env
    req.routes = routes
    req.engine_script_name = req.script_name
    req
  end
end
```

已经可以看到ActionDispatch的身影了