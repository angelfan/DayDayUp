require File.dirname(__FILE__) + '/route_set'

class Mapper
  def initialize(route_set)
    @route_set = route_set
  end

  def get(path, options = {})
    options[:via] = 'get'
    match(path, options)
  end

  # match 'path', to: 'controller#action', via: :post
  def match(path, options = {})
    method = options.fetch(:via)
    to = options.fetch(:to)
    add_route(path, method, to)
  end

  def add_route(path, method, to)
    @route_set.add_route(path, method, to)
  end
end
