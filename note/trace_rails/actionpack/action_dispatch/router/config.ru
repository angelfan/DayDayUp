require File.dirname(__FILE__) + '/router'

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
    your_name = req.params['your_name']
    [400, { 'Content-Type' => 'text/plain' }, ["hello: #{your_name}"]]
  end
end

router = Router.new.tap do |app|
  app.draw(:get, '/hello', 'welcome#hello')
end

run router

# http://localhost:9292/not_found
# http://localhost:9292/hello?your_name=angelfan
