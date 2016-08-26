# ActionDispatch::Routing::RouteSet
版本 `ActionPack::VERSION => 5.0.0(alpha)`

## 请求是怎么被分发的
### 例子
这玩意可以当rack app跑起来
```ruby
require 'action_dispatch'

Routes = ActionDispatch::Routing::RouteSet.new.tap do |app|
  app.draw do
    get 'tests', to: 'tests#welcome'
  end
end

class TestsController
  # 这段代码是我在rails v 4.2.6下面跑的
  # rails v 5.0 以后改成dispatch
  # https://github.com/rails/rails/blob/v4.2.7.1/actionpack/lib/action_dispatch/routing/route_set.rb#L73
  # https://github.com/rails/rails/blob/v5.0.0.beta1/actionpack/lib/action_dispatch/routing/route_set.rb#L50
  def self.action(method)
    controller = self.new
    controller.method(method.to_sym)
  end

  def welcome(env)
    [200, {"Content-Type" => "text/html"}, ["<h1>Hello</h1>"]]
  end
end

run Routes
# http://localhost:9292/tests
```

### 猜想
为什么可以这样, 根据Rack App的实现, 猜想可能是这样

`ActionDispatch::Routing::RouteSet` 里面应该会有个 `#call`, 然后根据当前的请求(env)分发到指定的Controller

env中会有我们想要的资料， 比如请求方法， 请求路径， 请求参数等等

请求方法+请求路径可以帮助我们找到对应的路由, 然后就可以根据定义的路由找到Controller#Action

然后按照Rack App 返回 status, head, body

咱们自己按照这种思路写一个试试看
```ruby
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
  def hello(env)
    your_name = env['QUERY_STRING'].split('=').last
    [400, { 'Content-Type' => 'text/plain' }, ["hello: #{your_name}"]]
  end
end

router = Router.new.tap do |app|
  # 为了检测猜想先这样简单实现下
  app.draw('/hello', { controller: 'HelloController', action: 'hello' })
end

run router

# http://localhost:9292/hello?name=yourname
```
恩, 可以跑起来了

### 看源码
先开始看 `RouteSet`
```ruby
# action_dispatch/routing/route_set.rb:710
class RouteSet
  class Dispatcher ... end # 平时总是喜欢说分发请求, 看名字好像跟它有关系

  def call(env)
    req = make_request(env)
    req.path_info = Journey::Router::Utils.normalize_path(req.path_info) # req.path_info => env['QUERY_STRING']
    @router.serve(req)
  end
end
```

的确有这么个东西， 它处理了一下env然后甩手就交给了 `@router.serve(req)`

找一下@router是什么东西
```ruby
# action_dispatch/routing/route_set.rb:324
def initialize(config = DEFAULT_CONFIG)
  ...
  @set    = Journey::Routes.new
  @router = Journey::Router.new @set
  ...
end
```

看一下`Journey::Router#serve`干了什么
```ruby
def serve(req)
  # 寻找目标路由
  find_routes(req).each do |match, parameters, route|
    ...
    status, headers, body = route.app.serve(req)
    ...
    return [status, headers, body]
  end

  return [404, {'X-Cascade' => 'pass'}, ['Not Found']]
end
```

route.app.serve => `ActionDispatch::Routing::RouteSet::Dispatcher#serve`
```ruby
# ActionDispatch::Routing::RouteSet
def serve(req)
  ...
  controller = controller req
  res        = controller.make_response! req
  dispatch(controller, params[:action], req, res)
  .....
end

def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)
  # 剩下的就交给Controller的类方法dispatch去处理了
end
```

基本流程就是

1. request进来后 `RouteSet` 把请求交给`Journey::Router`去处理

2. `Journey::Router`拿到request去找 `Route`

3. 然后执行Route#pp#serve,

4. Dispatcher(Route#app)取得request#controller_class然后调用Controller.dispatch

5. ActionController::Metal里面有个类方法 `self.dispatch(name, req, res)`他会负责将请求分发到指定的`Action`

ps: Route#app在rails5中有三种类型 `StaticDispatcher`, `Constraints`, `Dispatcher`
````ruby
def app(blocks)
  if to.is_a?(Class) && to < ActionController::Metal
    Routing::RouteSet::StaticDispatcher.new to
  else
    if to.respond_to?(:call)
      Constraints.new(to, blocks, Constraints::CALL)
    elsif blocks.any?
      Constraints.new(dispatcher(defaults.key?(:controller)), blocks, Constraints::SERVE)
    else
      dispatcher(defaults.key?(:controller)) # Routing::RouteSet::Dispatcher.new raise_on_name_error
    end
  end
end
````
整理一下思路, 写了如下迷你版demo

[迷你版demo](https://github.com/angelfan/DayDayUp/blob/master/note/learning_rails/actionpack/action_dispatch/router/config.ru)

## 另外两个感兴趣的问题
1. `Journey::Router` 是如何根据request找到对应的`Route`的
2. 'test/:id/hello/:name' 是如何将识别参数:id, :name的

先看一组测试用例
```ruby
paths = %w{
  /articles(.:format)
  /articles/:id/edit(.:format)
}
parser  = ActionDispatch::Journey::Parser.new
ast = paths.map { |x|
  ast = parser.parse x
  ast.each { |n| n.memo = x } # 实际上这个memo有两种值 nil || Route的实例对象
  ast
  # parser.parse x 会将路径变成一个个的节点 也就是Journey::Nodes里面的各种类型的节点
  # 并且该节点下面会带上正则表达式
  # 该正则有两个作用
  # 1. 将/articles/1231/edit的1231匹配出来将来作为params[:id]
  # 2. 生成TransitionTable表的@regexp_states, 因为也可能需要靠他来匹配路径 寻找memo中的路由(Route实例)索引
}

builder = ActionDispatch::Journey::GTG::Builder.new ActionDispatch::Journey::Nodes::Or.new ast
table = builder.transition_table

simulate = ActionDispatch::Journey::GTG::Simulator.new table

# 匹配到的路由
simulate.simulate('/articles/100/edit').memos
```


ast的memo本是空值, 在第一次开始寻找路由的时候才将其中为terminal?的结点赋值
```ruby
# ActionDispatch::Journey::Route
def ast
  @decorated_ast ||= begin
    decorated_ast = path.ast # 在Mapper#add_route的时候就已经建立了
    # 如果这个节点是终点就将当前的Route实例穿给该节点
    decorated_ast.find_all(&:terminal?).each { |n| n.memo = self }
    decorated_ast
  end
end
```
terminal的意思是一个路由的端点(不知道怎么翻译)

比如 '/articles' 它有两个端点, 一个是articles 另一个是format

因为我们的req#path_info可能是'/articles' 也可能是 '/articles.xxx',

simulate.simulate('/articles/100/edit')实际上是逐个去匹配,

'/', 'articles', '/', '100', '/', 'edit'

大概可能像是这样
```ruby
tring_states = {
    0 => {
        '/' => 1
    },
    1 => {
        'articles' => 2,
    },
    2 => {
        '/' => 3
    },
    4 => {
        '/'=> 5
    }
    5 => {
        'edit'=> '6(memo index)'
    }
}
regexp_states = {
    3 => {
        /[^\.\/\?]+/ => 4 #（用来匹配:id, 即100）
    }
}
```

为了更好的帮助我自己理解`TransitionTable` 整理了一段代码

[TransitionTable](https://github.com/angelfan/DayDayUp/blob/master/note/learning_rails/actionpack/action_dispatch/router_set/transition_table.rb)

上面那个动作之所以会被触发是因为在`Journey::Router#find_routes`过程中(请求进来了需要找到指定的路由以便按照上面所说的方式去分发请求)
会call`Journey::Route#ast`
```ruby
# ActionDispatch::Journey::Router
def find_routes req
  # 看方法名即知道有可能找到不止一个路由
  # 'articles/new'
  # 'articles/:id'
  # 按照匹配方式他们可以同时配  req.path_info => '/articles/new' 匹配到
  routes = filter_routes(req.path_info).concat custom_routes.find_all { |r|
    r.path.match(req.path_info)
  }

  # 解决方式就是按照路由书写的顺序来排列
  # resource :xxx的书写路由顺序是 index, create, new, edit, show, update(patch), update(put), destroy
  # 最终执行的时候执行完第一个路由就直接返回了
  routes.sort_by!(&:precedence)
  ...
end
```

所以 实际上寻找路由 是通过req#path_info去`TransitionTable`中去找

关于参数的问题 实际上就是
将'hello/:xx' 的路由生成一个 /\A\/hello\/([^\/.?]+)(?:\.([^\/.?]+))?\Z/ 正则
```ruby
reg = /\A\/hello\/([^\/.?]+)(?:\.([^\/.?]+))?\Z/
path_info = '/hello/name.js'
reg.match(path_info) # #<MatchData "/hello/name.js" 1:"name" 2:"js">
```

思路理得差不多, 然后参照一下rails中处理参数的方式 稍微完善一下之前的demo得到如下

[进阶版demo](https://github.com/angelfan/DayDayUp/blob/master/note/learning_rails/actionpack/action_dispatch/router_set/config.ru)

先这样吧~~~
