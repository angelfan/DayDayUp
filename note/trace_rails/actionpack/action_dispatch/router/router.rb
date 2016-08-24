# 这个版本主要做两件事情
# 1. 分离出Router, Request
# 2. draw(:get, '/hello', welcome#hello)
require 'active_support/all'

class Router
  # 分发的应该是请求即 request
  # 所以request里面应该能包含我们需要的信息, 比如 controller, action, params
  class Dispatcher
    def serve(req)
      controller = req.controller_class
      params = req.path_parameters
      controller.dispatch(params[:action], req)
    end
  end

  # routes => {'/hello': {methods: :get, resource: 'welcome#hello'}, ...}
  attr_accessor :routes

  def initialize
    super
    @routes = {}
  end

  def draw(method, path_info, resource)
    route_key = route_key(method, path_info)
    @routes[route_key] = { method: method, resource: resource }
  end

  def call(env)
    req = make_request(env)
    req.path_parameters = resource(req)

    Dispatcher.new.serve(req)
  end

  def request_class
    Request
  end

  private

  def make_request(env)
    request_class.new env
  end

  def route_key(method, path_info)
    [method.downcase.to_s, path_info.to_s].join('_')
  end

  def route(req)
    routes[route_key(req.request_method, req.path_info)]
  end

  def resource(req)
    route = route(req)
    if route
      resource = route[:resource]
      controller, action = resource.split('#')

      { controller: controller, action: action }
    else
      {}
    end
  end
end

# 每次去env取东西很不面向对象, 封装一下吧
# require 'rack/request'
class Request
  # 这些基本的东西rack/request已经封装好了 可以直接拿来用
  # 不过我们自己简单写一下好了
  # include Rack::Request::Helpers
  # include Rack::Request::Env

  attr_reader :env

  def initialize(env)
    @env = env
  end

  def get_header(name)
    env[name]
  end

  def set_header(name, value)
    env[name] = value
  end

  def path_info
    get_header('PATH_INFO')
  end

  def query_string
    get_header('QUERY_STRING')
  end

  def params
    query_string.split('&').each_with_object({}) do |v, params|
      param, value = v.split('=')
      params[param] = value
    end
  end

  def request_method
    get_header('REQUEST_METHOD')
  end

  # {'action' => 'my_action', 'controller' => 'my_controller'}
  def path_parameters
    get_header('path_parameters') || {}
  end

  def path_parameters=(path_parameters)
    set_header('path_parameters', path_parameters)
  end

  # 它好像不认识controller_class, 所以我们需要有一个地方来告诉它
  # 看了看上下文就地取材 就放到env中好了
  def controller_class
    params = path_parameters

    if params.key?(:controller)
      controller_param = params[:controller].underscore
      const_name = "#{controller_param.camelize}Controller"
      Object.const_get(const_name)
    else
      NotFoundError
    end
  rescue NameError => _e
    NotFoundError
  end

  class NotFoundError
    def self.dispatch(_method, _req)
      new.call
    end

    def call
      [404, { 'X-Cascade' => 'pass' }, ['not found']]
    end
  end
end

