## Example

```ruby
module ActiveRecord
  class StatsSubscriber < ActiveSupport::Subscriber
    attach_to :active_record

    def sql(event)
      Statsd.timing("sql.#{event.payload[:name]}", event.duration)
    end
  end
end

ActiveSupport::Notifications.instrument('sql.active_record', data: 123)
```


## subscriber

### attach_to

```ruby
def attach_to(namespace, subscriber=new, notifier=ActiveSupport::Notifications)
  @namespace  = namespace
  @subscriber = subscriber
  @notifier   = notifier

  subscribers << subscriber

  # Add event subscribers for all existing methods on the class.
  subscriber.public_methods(false).each do |event|
    add_event_subscriber(event)
  end
end

def add_event_subscriber(event)
  return if %w{ start finish }.include?(event.to_s)

  pattern = "#{event}.#{namespace}"

  # Don't add multiple subscribers (eg. if methods are redefined).
  return if subscriber.patterns.include?(pattern)

  subscriber.patterns << pattern
  notifier.subscribe(pattern, subscriber)
end
```

所以其实attach_to :active_record的作用就是
```ruby
ActiveSupport::Notifications.subscribe('sql.active_record', ActiveRecord::StatsSubscriber.new)
```
只不过会把public_methods全部subscribe 一个 ```method name``` + ```:active_record```

### ActiveSupport::Notifications.subscribe

```ruby
self.notifier = Fanout.new

def subscribe(*args, &block)
  notifier.subscribe(*args, &block)
end
```

所以
```ruby
ActiveSupport::Notifications.subscribe('sql.active_record', ActiveRecord::StatsSubscriber.new)
等价于
ActiveSupport::Notifications.notifier.subscribe('sql.active_record', ActiveRecord::StatsSubscriber.new)
而ActiveSupport::Notifications.notifier 是 Fanout的一个实例
所以等价于
notifier = ActiveSupport::Notifications::Fanout.new
notifier.subscribe('name.person', PersonSubscriber.new)
ActiveSupport::Notifications.notifier = notifier
```

```ruby
class Fanout
  include Mutex_m

  def initialize
    @subscribers = []
    @listeners_for = Concurrent::Map.new
    super
  end

  def subscribe(pattern = nil, block = Proc.new)
    subscriber = Subscribers.new pattern, block
    synchronize do
      @subscribers << subscriber
      @listeners_for.clear
    end
    subscriber
  end
end
```

### Subscribers.new pattern, block

```ruby
def self.new(pattern, listener)
  if listener.respond_to?(:start) and listener.respond_to?(:finish)
    subscriber = Evented.new pattern, listener
  else
    subscriber = Timed.new pattern, listener
  end

  unless pattern
    AllMessages.new(subscriber)
  else
    subscriber
  end
end
```
ActiveRecord::StatsSubscriber 会被 Evented.new 'sql.active_record', ActiveRecord::StatsSubscriber.new

到此 subscriber 建立完毕
notifier其实就是ActiveSupport::Notifications::Fanout.new
notifier里面存储了subscribers
Evented类型subscriber
```ruby
class Evented #:nodoc:
  def initialize(pattern, delegate)
    @pattern = pattern
    @delegate = delegate
    @can_publish = delegate.respond_to?(:publish)
  end

  def publish(name, *args)
    if @can_publish
      @delegate.publish name, *args
    end
  end

  def start(name, id, payload)
    @delegate.start name, id, payload
  end

  def finish(name, id, payload)
    @delegate.finish name, id, payload
  end

  def subscribed_to?(name)
    @pattern === name
  end

  def matches?(name)
    @pattern && @pattern === name
  end
end
```

## instrument

### ActiveSupport::Notifications.instrument

```ruby
def instrument(name, payload = {})
  if notifier.listening?(name)
    instrumenter.instrument(name, payload) { yield payload if block_given? }
  else
    yield payload if block_given?
  end
end

def instrumenter
  InstrumentationRegistry.instance.instrumenter_for(notifier)
end
```

首先需要判断一下notifier是否监听了该事件
即判断ActiveSupport::Notifications::Fanout里面的subscribers是否监听了该事件
```ruby
def listeners_for(name)
  # this is correctly done double-checked locking (Concurrent::Map's lookups have volatile semantics)
  @listeners_for[name] || synchronize do
    # use synchronisation when accessing @subscribers
    @listeners_for[name] ||= @subscribers.select { |s| s.subscribed_to?(name) }
  end
end

def listening?(name)
  listeners_for(name).any?
end
```
如果有subscriber监听了该事件
ActiveSupport::Notifications::Instrumenter#instrument
```ruby
def instrument(name, payload={})
  # some of the listeners might have state
  listeners_state = start name, payload
  begin
    yield payload
  rescue Exception => e
    payload[:exception] = [e.class.name, e.message]
    raise e
  ensure
    finish_with_state listeners_state, name, payload
  end
end

def start(name, payload)
  @notifier.start name, @id, payload
end

# Send a finish notification with +name+ and +payload+.
def finish(name, payload)
  @notifier.finish name, @id, payload
end

def finish_with_state(listeners_state, name, payload)
  @notifier.finish name, @id, payload, listeners_state
end
```
最终会调用subscriber 即 ActiveSupport::Subscriber的#start和#finish
```ruby
def start(name, id, payload)
  e = ActiveSupport::Notifications::Event.new(name, Time.now, nil, id, payload)
  parent = event_stack.last
  parent << e if parent

  event_stack.push e
end

def finish(name, id, payload)
  finished  = Time.now
  event     = event_stack.pop
  event.end = finished
  event.payload.merge!(payload)

  method = name.split('.'.freeze).first
  send(method, event) # send('sql', event)
end
```

## 总结

ActiveSupport::Subscriber 主要三个方法
```
#attach_to 订阅事件的namespace
#start 事件instrument会被执行
#new 事件instrument会被执行
```
ActiveSupport::Notifications::Event
可以看做是某事件一个生命周期的抽象

ActiveSupport::Notifications
负责分发事件, 他维护了两个抽象层
1. 一个类变量级别的实例 notifier 即ActiveSupport::Notifications::Fanout.new
2. instrumenter 即Instrumenter.new(notifier)

ActiveSupport::Notifications::Fanout
管理subscribers， 当时事件instrument时 负责将事件委托到将订阅该事件的subscribers

ActiveSupport::Notifications::Instrumenter
分发到具体事件事件 然后委托到


## PS
```ruby
class OtherSubscriber < ActiveSupport::Subscriber
  attach_to :other

  def publish(name, *args)
  end

  def any_name
  end
end

ActiveSupport::Notifications.publish('any_name.other', date: 'any_date')

publish一个时间全部会被代理到 OtherSubscriber#publish上
可以通过它来自定一些事情
```
