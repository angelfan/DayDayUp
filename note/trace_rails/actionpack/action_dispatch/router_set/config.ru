require File.dirname(__FILE__) + '/route_set'

class WelcomeController
  def self.dispatch(method, req)
    controller = new(req)
    controller.send(method.to_sym)
  end

  attr_reader :req

  def initialize(req)
    @req = req
  end

  def hello
    your_name = req.params['name']
    [200, { 'Content-Type' => 'text/plain' }, ["hello: #{your_name}"]]
  end

  def match
    [200, { 'Content-Type' => 'text/plain' }, ["format: #{req.params['format']}"]]
  end
end

router = RouteSet.new.draw do
  get 'hello', to: 'welcome#hello'
  get 'hello/:name', to: 'welcome#hello'
  match 'match', to: 'welcome#match', via: 'get'
end

run router

# http://localhost:9292/not_found
# http://localhost:9292/hello?name=angelfan
# http://localhost:9292/hello/legend?name=angelfan
# http://localhost:9292/match.html
