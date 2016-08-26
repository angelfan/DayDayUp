class Router
  attr_accessor :routes

  def initialize
    super
    @routes = {}
  end

  def call(env)
    resource = routes[env['PATH_INFO']]
    controller = Object.const_get(resource[:controller]).new
    action = resource[:action]
    dispatch(controller, action, env)
  end

  def dispatch(controller, action, env)
    controller.send(action, env)
  end

  def draw(path, resource)
    routes[path] = resource
  end
end

class HelloController
  def hello(_env)
    your_name = _env['QUERY_STRING'].split('=').last
    [400, { 'Content-Type' => 'text/plain' }, ["hello: #{your_name}"]]
  end
end

router = Router.new.tap do |app|
  app.draw('/hello', { controller: 'HelloController', action: 'hello' })
end

run router

# copy it to config.ru
# $ rackup
# http://localhost:9292/hello?name=yourname
