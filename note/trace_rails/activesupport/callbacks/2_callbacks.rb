require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

# 进阶版*1 支持before after 的 callback chain
module Callbacks
  extend ActiveSupport::Concern

  def run_callbacks(kind, &block)
    send "_run_#{kind}_callbacks", &block
  end

  def __run_callbacks__(callbacks, &block)
    callbacks.call(self, &block)
  end

  class Callback
    attr_accessor :name, :filter, :kind

    def initialize(name, filter, kind)
      @name = name
      @filter = filter
      @kind = kind
    end

    def apply(target)
      filter.send(kind, target)
    end
  end

  # 每一个Callback实例都存放在 before_chain or after_chain 中
  class CallbackChain
    attr_accessor :name, :before_chain, :after_chain

    def initialize(name)
      @name = name
      @before_chain = []
      @after_chain = []
    end

    def insert(callback)
      if callback.kind == :before
        before_chain << callback
      elsif callback.kind == :after
        after_chain << callback
      else
        # something
      end
    end

    def call(target, &block)
      before_chain.each do |callback|
        callback.apply(target)
      end
      value = block.call
      after_chain.each do |callback|
        callback.apply(target)
      end
      value # 保证最终返回值依然调用函数的返回值
    end
  end

  module ClassMethods
    def define_callbacks(*names)
      names.each do |name|
        class_attribute "_#{name}_callbacks"
        set_callbacks name, CallbackChain.new(name)

        module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def _run_#{name}_callbacks(&block)
              __run_callbacks__(_#{name}_callbacks, &block)
            end
        RUBY
      end

      def set_callback(name, kind, filetr)

        get_callbacks(name).insert(Callback.new(name, filetr, kind))
      end
    end

    protected

    def get_callbacks(name)
      send "_#{name}_callbacks"
    end

    def set_callbacks(name, callbacks)
      send "_#{name}_callbacks=", callbacks
    end
  end
end

class Audit
  def before(caller)
    puts caller.name
    puts 'Audit: before is called'
  end

  def after(_caller)
    puts 'Audit: after is called'
  end
end

class Audit2
  def before(_caller)
    puts 'Audit2: before is called'
  end
end

class Account
  include Callbacks
  attr_accessor :name
  define_callbacks :save
  set_callback :save, :before, Audit.new
  set_callback :save, :after, Audit.new
  set_callback :save, :before, Audit2.new

  def save
    run_callbacks :save do
      puts 'save in main'
    end
  end
end

account = Account.new
account.name = 'account name'
account.save