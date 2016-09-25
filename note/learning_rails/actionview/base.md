# 尝试理解ActionController::Base#render
我是带着以下两个问题去翻ActionView相关的源码的, 标题是后来取的

1. 是通过什么手段将controller的实例变量复制到view中的
2. 这些实例变量是怎么被使用的, 是怎将erb(也可能是slim haml等)转化成标准的html的

在我们的controller的书写中 是通过render来渲染view的
比如我们会写:
```ruby
def index
  render :index
end

# 虽然我们一般不写, 不过最终还是会调用render
# actionpack/lib/action_controller/metal/implicit_render.rb中实现了隐式调用
# 就是通过重写send_action
# send_action 原名send, 在AbstractController::Base#process_action中被调用
# process_action在识别路由分发请求之后会被调用, 
# https://ruby-china.org/topics/30916简单介绍了下rails如何识别路由并转发到对应的controller
```
接下来 我的切入点就变成寻找`#render`

## 从`#render`开始
```ruby
# actionpack/lib/abstract_controller/rendering.rb
# 它在ActionController::Base中被include
# 同时ActionController::Base还include ActionView::Layouts(这是controller转战view的关键点)
# 详细include了那些模块看actionpack/lib/action_controller/base.rb

module AbstractController
  module Rendering

    def render(*args, &block)
      options = _normalize_render(*args, &block)
      rendered_body = render_to_body(options)
      if options[:html]
        _set_html_content_type
      else
        _set_rendered_content_type rendered_format
      end
      self.response_body = rendered_body
    end
  end
end
```

一看就知道render_to_body是关键点(response_boy内容全靠它)
ActionController::Base中引用了太多的模块很多方法被多个模块不断的重写, 不同模块的重写附加的职能是不同的
为了知道一个方法被那些模块重写 把下面这段代码复制粘贴到`rails c`下就能用

```ruby
class Module
  def ancestors_that_implement_instance_method(instance_method)
    ancestors.find_all do |ancestor|
      (ancestor.instance_methods(false) + ancestor.private_instance_methods(false)).include?(instance_method)
    end
  end
end
```

`#_normalize_render`
```ruby
# actionpack/lib/abstract_controller/rendering.rb 
# AbstractController::Rendering
# render各种用法详见 http://guides.rubyonrails.org/layouts_and_rendering.html
# 这里主要是对参数进行处理
# 比如是否需要特别处理 例如render status: 200
# 是否需要套用layout
# 是否需要加上prefixes  => YourControler._prefixes
# 处理完之后才会交给render_to_body, 因为它需要就根据你写的代码见招拆招
def _normalize_render(*args, &block)
  options = _normalize_args(*args, &block)
  if defined?(request) && !request.nil? && request.variant.present?
    options[:variant] = request.variant
  end

  _normalize_options(options)
  options
end

# 贴一下这两个方法被那些模块重写过
ActionController::Base.ancestors_that_implement_instance_method(:_normalize_args)
# [
#     [0] ActionController::Rendering,
#     [1] ActionView::Rendering,
#     [2] AbstractController::Rendering
# ]

ActionController::Base.ancestors_that_implement_instance_method(:_normalize_options)
# [
#     [0] ActionController::Rendering,
#     [1] ActionView::Layouts,
#     [2] ActionView::Rendering,
#     [3] AbstractController::Rendering
# ]
```

## 进入render_to_body
先看一下哪些地方重写了`#render_to_body`
```ruby
ActionController::Base.ancestors_that_implement_instance_method(:render_to_body)
# rails5中会搜到了5个同名方法 api那边会重写一次
# [
#     [0] ActionController::Renderers, # 负责处理:json, :js, :xml等
#     [1] ActionController::Rendering, # 负责处理 :body, :text, :plain, :html
#     [2] ActionView::Rendering, #  恩 这个就是我要找的
#     [3] AbstractController::Rendering # 它什么都不干 就是一个接口, 毕竟人家叫Abstract
# ]
```

```ruby
# actionview/lib/action_view/rendering.rb
module ActionView
  module Rendering
    def render_to_body(options = {})
      _process_options(options)
      _render_template(options)
    end
  end
end
```

主要看_render_template
```ruby
# 到这里我的第一个问题的答案就水落石出了(是通过什么手段将controller的实例变量复制到view中的)
def _render_template(options) #:nodoc:
  variant = options.delete(:variant)
  assigns = options.delete(:assigns)
  context = view_context

  context.assign assigns if assigns
  lookup_context.rendered_format = nil if options[:formats]
  lookup_context.variants = variant if variant

  view_renderer.render(context, options)
end

def view_context
  view_context_class.new(view_renderer, view_assigns, self)
end

# view_context接受三个参数, 其中包括view_assigns
def view_assigns
  protected_vars = _protected_ivars
  variables      = instance_variables

  variables.reject! { |s| protected_vars.include? s }
  variables.each_with_object({}) { |name, hash|
    hash[name.slice(1, name.length)] = instance_variable_get(name)
  }
end

# #view_assigns会把我们在controller中定义的实例变量拿过来先放到hash中存起来, 不过会去掉_protected_ivars(实现这套框架引入的实例变量)
# 然后交给ActionView::Base
def initialize(context = nil, assigns = {}, controller = nil, formats = nil) #:nodoc:
  ...
  assign(assigns)
  ...
end

# 将hash通过instance_variable_set变成view(ActionView::Base)的实例变量
def assign(new_assigns) # :nodoc:
  @_assigns = new_assigns.each { |key, value| instance_variable_set("@#{key}", value) }
end
```
`OK` 第一个问题解决, 我之前的另一个猜测是用了[binding](https://ruby-doc.org/core-2.2.0/Binding.html)

继续寻找第二个问题的答案
`#view_context`
```ruby
def view_context_class
  @view_context_class ||= begin
    ......
    # 这就是为什么在view中输出self.class是匿名的class
    Class.new(ActionView::Base) do
      if routes
        include routes.url_helpers(supports_path)
        include routes.mounted_helpers
      end

      if helpers
        include helpers
      end
    end
  end
end

def view_context
  # self就是当前controller的实例
  view_context_class.new(view_renderer, view_assigns, self)
end
```

`#lookup_context`
```ruby
def lookup_context
  @_lookup_context ||=
    ActionView::LookupContext.new(self.class._view_paths, details_for_lookup, _prefixes)
end

# 它知道要去哪里找view
# YourController.new.lookup_context.view_paths.paths
```

`#view_renderer`
```ruby
def view_renderer
  @_view_renderer ||= ActionView::Renderer.new(lookup_context)
end

# 它知道什么情况下怎么处理, 比如render text: 'xx', render html: 'xx' 等等
```
看到这里我一开始其实是有点迷糊的
因为在_render_template中最终通过view_renderer#render输出
为什么view_context还要拿个view_renderer在手里
后来才想起来在view中也会render 它同样要依靠ActionView::Renderer

通过运行 `ActionView::Base.ancestors_that_implement_instance_method(:render)`
会发先view中的`#render`在ActionView::Helpers::RenderingHelper中
```ruby
module ActionView
  module Helpers
    # = Action View Rendering
    #
    # Implements methods that allow rendering from a view context.
    # In order to use this module, all you need is to implement
    # view_renderer that returns an ActionView::Renderer object.
    module RenderingHelper
    end
  end
end
# 看文档注释 果然是这样
```

通过猜+翻看注释 发现我寻找答案应该是在view_renderer中, 一路看下去
```ruby
module ActionView
  class Renderer
    def render(context, options)
      if options.key?(:partial)
        render_partial(context, options)
      else
        render_template(context, options)
      end
    end
    
    # 只看render_template好了
    def render_template(context, options) #:nodoc:
      TemplateRenderer.new(@lookup_context).render(context, options)
    end
  end
end

def render_template(template, layout_name = nil, locals = nil) #:nodoc:
  view, locals = @view, locals || {}

  render_with_layout(layout_name, locals) do |layout|
    instrument(:template, identifier: template.identifier, layout: layout.try(:virtual_path)) do
      template.render(view, locals) { |*name| view._layout_for(*name) }
    end
  end
end

# 最终进入
module ActionView
  # = Action View Template
  class Template
  
    def render(view, locals, buffer=nil, &block)
      instrument_render_template do
        compile!(view)
        view.send(method_name, locals, buffer, &block)
      end
    rescue => e
      handle_render_error(view, e)
    end
    
    def compile!(view) #:nodoc:
      return if @compiled

      @compile_mutex.synchronize do
        ...

        instrument("!compile_template") do
          compile(mod)
        end

        ...
      end
    end
    
    def compile(mod) #:nodoc:
      ...
      method_name = self.method_name
      code = @handler.call(self)

      source = <<-end_src
        def #{method_name}(local_assigns, output_buffer)
          _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{locals_code};#{code}
        ensure
          @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
        end
      end_src

      mod.module_eval(source, identifier, 0)
      ObjectSpace.define_finalizer(self, Finalizer[method_name, mod])
    end
    
    def method_name #:nodoc:
      @method_name ||= begin
        m = "_#{identifier_method_name}__#{@identifier.hash}_#{__id__}"
        m.tr!('-', '_')
        m
      end
    end
  end
end

```

`code = @handler.call(self)`

@handler => ActionView::Template::Handlers::ERB

self => ActionView::Template

它会输出一串字符串

就像 `ActionView::Template::Handlers::Erubis.new("<h1><%= @abc %></h1>").src` 会输出

`"@output_buffer = output_buffer || ActionView::OutputBuffer.new;@output_buffer.safe_append='<h1>'.freeze;@output_buffer.append=( @abc );@output_buffer.safe_append='</h1>'.freeze;@output_buffer.to_s"`

这样相当于
```ruby
def method_name(local_assigns, output_buffer) # method_name每次都不一样, 用完之后会通过#define_finalizer回收
  ...
  @output_buffer = output_buffer || ActionView::OutputBuffer.new;@output_buffer.safe_append='<h1>'.freeze
  @output_buffer.append=( @abc )
  @output_buffer.safe_append='</h1>'.freeze
  @output_buffer.to_s
  ...
end
```

这个方法通过 `mod.module_eval(source, identifier, 0)` 作用到ActionView::Base上了
所以可以抓到`@abc`这个实例变量

至此完成erb到html的转换

两个问题解完