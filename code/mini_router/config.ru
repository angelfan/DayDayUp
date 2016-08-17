class Router
  def initialize
    super
  end

  def call(env)
    resource = routes[env['REQUEST_PATH']]
    controller = Object.const_get(resource[:controller]).new
    action = resource[:action]
    dispatch(controller, action, env)
  end

  def dispatch(controller, action, env)
    controller.send(action, env)
  end

  def routes
    @routes ||= {}
  end

  def add_routes(path, resource)
    routes[path]
    routes[path] = resource
  end
end



class HelloController
  def hello(env)
    [400, { 'Content-Type' => 'text/plain' }, ['hello']]
  end
end


router = Router.new
router.add_routes('/hello', { controller: 'HelloController', action: 'hello' })
run router
# rackup
