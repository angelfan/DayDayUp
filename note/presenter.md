# presenter on rails

ruby on rails 属于 MVC 框架, 对于简单的应用三层可能就够用了，
但是当应用越来越复杂可能就需要更多的抽象层来满足业务需求， 比如service, presenter
比如有些人认为应用逻辑(业务逻辑)不应该放在数据层(Model)，或者一个 Model 只应该管好他自己的事情，多个 Model 的融合需要另外的类来做代理。

## Model != View

很多情况下， view中会有这样的类似写法 ```@article.published? && @article.user_type == 'Admin'```
也许可以把他放到model中定义出一个方法， 比如
```ruby
class Artice < ActiveRecord::Base
    def published_by_admin?
        published? && user_type == 'Admin
    end
end
```
或者你也可以把他放到 helper中去
然后view中就可以这样用```@article.published_by_admin```
但是随着逻辑越来越多， model中类似的方法也会越来越多, 但是model中应该主要用来放业务逻辑
所以需要额外抽象出presenter层来处理

## Demo


```ruby
## 代码链接 https://github.com/railscasts/287-presenters-from-scratch
class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def object
    @object
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  # this allows any template methods to be called directly from presenter code.
  def method_missing(*args, &block)
    # TODO check for @template.respond_to? and return raw values if nil
    @template.send(*args, &block)
  end
end

class UserPresenter < BasePresenter
  presents :user
  delegate :username, to: :user

  def full_name
    "#{first_name}-#{last_name}"
  end
end


# helper 中增加该方法
module ApplicationHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end

# in view
<% present @user do |user_presenter| %>
    <p><%= user_presenter.fullname %></p>
<% end %>
```
这样不管是model 还是 helper都会变得很干净， 最重要的是 变得更容易测试

推荐的gem [Draper](https://github.com/drapergem/draper)