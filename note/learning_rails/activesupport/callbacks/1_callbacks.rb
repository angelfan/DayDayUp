require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

# 最简版: 只能有一个before callback
module Callbacks
  extend ActiveSupport::Concern

  def run_callbacks(kind, &block)
    send "_run_#{kind}_callbacks", &block
  end

  def __run_callbacks__(callbacks, &block)
    callbacks.call(self, &block)
  end

  class Callback
    attr_accessor :name, :callback

    def initialize(name, callback)
      @name = name
      @callback = callback
    end

    def call(target)
      callback.send(:before, target)
    end
  end

  module ClassMethods
    def define_callbacks(*names)
      names.each do |name|
        class_attribute "_#{name}_callbacks"
        set_callbacks name, Callback.new(name, nil)

        module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def _run_#{name}_callbacks(&block)
              __run_callbacks__(_#{name}_callbacks, &block)
            end
        RUBY
      end

      def set_callback(name, klass)
        get_callbacks(name).callback = klass
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
end

class Account
  include Callbacks
  attr_accessor :name
  define_callbacks :save
  set_callback :save, Audit.new

  def save
    run_callbacks :save do
      puts 'save in main'
    end
  end
end

account = Account.new
account.name = 'account name'
account.save