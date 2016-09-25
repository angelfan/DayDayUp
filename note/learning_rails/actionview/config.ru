require 'action_dispatch'
require 'action_controller'

routes = ActionDispatch::Routing::RouteSet.new
routes.draw do
  get '/' => 'test#index'
end

class TestController < ActionController::Metal
  include AbstractController::Rendering

  def index
    @var = 'you had got the instance variable'
    render 'index'
    # 这个'index'在我们整理其实是无意义的, 其实可以render任何
    # 比如 render 'xxx', 因为我们的render_to_body没有使用这些参数
  end

  def render_to_body(*_args)
    template = ERB.new File.read("#{params[:action]}.html.erb")
    template.result(binding)
  end
end

run routes