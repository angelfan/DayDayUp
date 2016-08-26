require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

# 进阶版*3 支持guard
module Callbacks
  extend ActiveSupport::Concern

  # 提取出构造callback执行的上下文环境
  Environment = Struct.new(:target, :run_block)

  def run_callbacks(kind, &block)
    send "_run_#{kind}_callbacks", &block
  end

  def __run_callbacks__(callbacks, &block)
    e = Environment.new(self, block)
    callbacks.call(e)
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
      user_callback =  make_lambda(filter)
      user_callback.call(target)
    end

    def invert_lambda(l)
      lambda { |*args, &blk| !l.call(*args, &blk) }
    end

    def conditions_lambdas
      @if.map { |c| make_lambda c } + @unless.map { |c| invert_lambda make_lambda c }
    end

    # 把他们通通转成 lambda
    def make_lambda(filter)
      case filter
        when Symbol
          lambda { |target| target.send filter }
        else
          lambda { |target|
            filter.public_send kind, target
          }
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
      else
        # something
      end
    end

    def call(e)
      before_chain.each do |callback|
        callback.apply(e.target) if callback.conditions_lambdas.all? { |c| c.call(e.target) == true }
      end
      value =  e.run_block.call
      after_chain.each do |callback|
        callback.apply(e.target) if callback.conditions_lambdas.all? { |c| c.call(e.target) == true }
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

class Audit
  def before(caller)
    puts caller.name
    puts 'Audit: before is called'
  end

  def after(_caller)
    puts 'Audit: after is called'
  end
end

class Account
  include Callbacks
  attr_accessor :name
  define_callbacks :save
  set_callback :save, :before, Audit.new
  set_callback :save, :after, Audit.new
  set_callback :save, :after, :after_save_yes, if: :new_account_name?
  set_callback :save, :after, :after_save_no, if: [:new_account_name?, :account_name?]
  set_callback :save, :after, :after_save_ok, unlee: :account_name?

  def after_save_yes
    puts 'after_save_yes'
    puts name # new account name
  end

  def after_save_no
    puts 'after_save_no'
  end

  def after_save_ok
    puts 'after_save_ok'
  end

  def save
    run_callbacks :save do
      self.name = 'new account name'
      puts 'save in main'
    end
  end

  def new_account_name?
    name == 'new account name'
  end

  def account_name?
    name == 'account name'
  end
end

account = Account.new
account.name = 'account name'
account.save