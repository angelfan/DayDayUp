require File.dirname(__FILE__) + '/route'
require File.dirname(__FILE__) + '/mapper'
require File.dirname(__FILE__) + '/request'

class RouteSet
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
    @routes = []
  end

  def draw(&block)
    mapper = Mapper.new(self)
    mapper.instance_exec(&block)
  end

  def add_route(path, method, to)
    route = Route.new(path, method, to)
    @routes << route
    self
  end

  def call(env)
    req = make_request(env)
    route = find_route(req)
    if route
      req.path_parameters = route.path_parameters
      req.params.merge!(route.path.match_data(req.path_info).captures)
    end
    Dispatcher.new.serve(req)
  end

  def find_route(req)
    routes.find { |route| route.path.match?(req.path_info, req.request_method) }
  end

  private

  def make_request(env)
    Request.new(env)
  end
end
