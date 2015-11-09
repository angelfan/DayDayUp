## path rails/activesupport/lib/active_support/lazy_load_hooks.rb

module TestActiveSupport
  # 构建一个Hash数组
  @load_hooks = Hash.new {|h,k| h[k] = [] }
  @loaded = {}

  def self.on_load(name, options = {}, &block)
    if base = @loaded[name]
      execute_hook(base, options, block)
    else
      @load_hooks[name] << [block, options]
    end
  end

  def self.execute_hook(base, options, block)
    if options[:yield]
      block.call(base)
    else
      base.instance_eval(&block)
    end
  end

  def self.run_load_hooks(name, base = Object)
    @loaded[name] = base
    @load_hooks[name].each do |hook, options|
      execute_hook(base, options, hook)
    end
  end
end

TestActiveSupport.on_load :load_name do
  p 'load_name 1'
end

TestActiveSupport.on_load :load_name do
  p 'load_name 2'
end

TestActiveSupport.on_load :load_other do
  p 'load_other'
end

TestActiveSupport.run_load_hooks(:load_name) # load_name 1, 2
TestActiveSupport.run_load_hooks(:load_other) # load_other


class Color
  def initialize(name)
    @name = name

    TestActiveSupport.run_load_hooks(:instance_of_color, self)
  end
end

TestActiveSupport.on_load :instance_of_color do
  puts "The color is #{@name}"
end

Color.new("yellow") # => "The color is yellow"


class HttpClient
  # ...

  TestActiveSupport.run_load_hooks(:http_client, self)
end


class Request
  # ...

  TestActiveSupport.on_load :http_client do
    # do something
  end
end