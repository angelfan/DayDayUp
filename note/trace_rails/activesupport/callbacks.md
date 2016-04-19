## Example

```ruby
class Audit
  def before(caller)
    puts 'Audit: before is called'
  end

  def before_save(caller)
    puts 'Audit: before_save is called'
  end
end

class Account
  include ActiveSupport::Callbacks

  define_callbacks :save
  set_callback :save, :before, Audit.new

  def save
    run_callbacks :save do
      puts 'save in main'
    end
  end
end
```

## analysis

### define_callbacks :save

```ruby
def define_callbacks(*names)
  options = names.extract_options!

  names.each do |name|
    class_attribute "_#{name}_callbacks"
    set_callbacks name, CallbackChain.new(name, options)

    module_eval <<-RUBY, __FILE__, __LINE__ + 1
      def _run_#{name}_callbacks(&block)
        __run_callbacks__(_#{name}_callbacks, &block)
      end
    RUBY
  end
end
```

1. names.extract_options! 提取options
2. class_attribute "_#{name}_callbacks"
3. set_callbacks name, CallbackChain.new(name, options)
4. 定义 #_run_#{name}_callbacks(&block) 这个方法实际上调用的是 # __run_callbacks__

#### set_callbacks

```ruby
def set_callbacks(name, callbacks) # :nodoc:
  send "_#{name}_callbacks=", callbacks
end
```
实际上就是把 CallbackChain 给 class_attribute "_#{name}_callbacks"

基本上 define_callback 就干了这些事情

### set_callback :save, :before, Audit.new

set_callback != set_callbacks

```ruby
def set_callback(name, *filter_list, &block)
  type, filters, options = normalize_callback_params(filter_list, block)
  # type => save
  # filters => [Audit.new]
  # block => nil

  self_chain = get_callbacks name
  # 拿到 callbacks 即 CallbackChain.new(name, {})
  mapped = filters.map do |filter|
    Callback.build(self_chain, filter, type, options)
  end
  # Callback其实就是需要回调的函数 在这里是Audit

  # 然后 把它塞到最开始
  # set_callbacks name, CallbackChain.new(name, options)
  __update_callbacks(name) do |target, chain|
    options[:prepend] ? chain.prepend(*mapped) : chain.append(*mapped)
    target.set_callbacks name, chain
  end
end
```

### Account.new.save
这个时候回调用一个方法 run_callbacks :save

#### run_callbacks

```ruby
def run_callbacks(kind, &block)
  send "_run_#{kind}_callbacks", &block
end
# 其实他就是 调用了 在define_callbacks :save时候定义的 #_run_#{name}_callbacks(&block)
# 所以实际上 这个方法是调用了 __run_callbacks__
```

```ruby
def __run_callbacks__(callbacks, &block)
  if callbacks.empty?
    yield if block_given?
  else
    runner = callbacks.compile
    e = Filters::Environment.new(self, false, nil, block)
    runner.call(e).value
  end
end
```
runner 就是回调链 CallbackChain => CallbackSequence
e 其实就是回调链的调用者 这里就是Account.new

#### callbacks.compile
```ruby
def compile
  @callbacks || @mutex.synchronize do
    final_sequence = CallbackSequence.new { |env| Filters::ENDING.call(env) }
    @callbacks ||= @chain.reverse.inject(final_sequence) do |callback_sequence, callback|
      callback.apply callback_sequence
    end
  end
end
```

#### callback.apply callback_sequence
```ruby
def apply(callback_sequence)
  user_conditions = conditions_lambdas
  user_callback = make_lambda @filter

  case kind
  when :before
    Filters::Before.build(callback_sequence, user_callback, user_conditions, chain_config, @filter)
  when :after
    Filters::After.build(callback_sequence, user_callback, user_conditions, chain_config)
  when :around
    Filters::Around.build(callback_sequence, user_callback, user_conditions, chain_config)
  end
end
```

#### runner.call(e).value

```ruby
def call(arg)
  @before.each { |b| b.call(arg) }
  value = @call.call(arg)
  @after.each { |a| a.call(arg) }
  value
end
```
就是将每个类型的回调链里面所有的callback 全部执行一遍

### callback从不懂到装懂

#### [最简版:](https://github.com/angelfan/DayDayUp/tree/master/note/trace_rails/activesupport/callbacks/1_callbacks.rb) 只能有一个before callback
#### [进阶版*1](https://github.com/angelfan/DayDayUp/tree/master/note/trace_rails/activesupport/callbacks/2_callbacks.rb) 支持before after 的 callback chain
#### [进阶版*2](https://github.com/angelfan/DayDayUp/tree/master/note/trace_rails/activesupport/callbacks/3_callbacks.rb) 支持方法回调 支持类回调
#### [进阶版*3](https://github.com/angelfan/DayDayUp/tree/master/note/trace_rails/activesupport/callbacks/4_callbacks.rb) 支持guard

