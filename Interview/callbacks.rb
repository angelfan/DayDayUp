require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

module Callbacks
  extend ActiveSupport::Concern

  Environment = Struct.new(:target, :run_block)

  def run_callbacks(kind, &block)
    send "_run_#{kind}_callbacks", &block
  end

  def __run_callbacks__(callbacks, &block)
    env = Environment.new(self, block)
    callbacks.call(env)
  end

  class Callback
    attr_accessor :name, :filter, :kind

    def initialize(name, filter, kind, options)
      @name = name
      @filter = filter
      @kind = kind
      @if      = Array(options[:if])
      @unless  = Array(options[:unless])
    end

    def apply(target)
      user_callback = make_lambda(filter)
      user_callback.call(target)
    end

    def invert_lambda(l)
      ->(*args, &blk) { !l.call(*args, &blk) }
    end

    def conditions_lambdas
      @if.map { |c| make_lambda c } + @unless.map { |c| invert_lambda make_lambda c }
    end

    def make_lambda(filter)
      case filter
      when Symbol
        ->(target) { target.send filter }
      else
        lambda do |target|
          filter.public_send kind, target
        end
      end
    end
  end

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
        # something
      end
    end

    def call(env)
      before_chain.each do |callback|
        callback.apply(env.target) if callback.conditions_lambdas.all? { |c| c.call(env.target) == true }
      end
      value = env.run_block.call
      after_chain.each do |callback|
        callback.apply(env.target) if callback.conditions_lambdas.all? { |c| c.call(env.target) == true }
      end
      value
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

      def set_callback(name, kind, klass, options = {})
        get_callbacks(name).insert(Callback.new(name, klass, kind, options))
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
