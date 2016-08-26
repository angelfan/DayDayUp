require 'active_support/all'

module MyCallbacks
  extend ActiveSupport::Concern
  include ActiveSupport::Callbacks

  included do
    define_callbacks :process,
                     terminator: ->(processor, _) { processor.payload },
                     skip_after_callbacks_if_terminated: true
  end

  def process(*args)
    run_callbacks(:process) do
      super
    end
  end

  module ClassMethods
    def _normalize_callback_options(options)
      _normalize_callback_option(options, :only, :if)
      _normalize_callback_option(options, :except, :unless)
    end

    def _normalize_callback_option(options, from, to) # :nodoc:
      if from = options[from]
        from = Array(from).map { |o| "process_name == '#{o}'" }.join(" || ")
        options[to] = Array(options[to]).unshift(from)
      end
    end

    def skip_process_callback(*names)
      skip_before_process(*names)
      skip_after_process(*names)
      skip_around_process(*names)
    end

    alias_method :skip_process, :skip_process_callback

    def _insert_callbacks(callbacks, block = nil)
      options = callbacks.extract_options!
      _normalize_callback_options(options)
      callbacks.push(block) if block
      callbacks.each do |callback|
        yield callback, options
      end
    end

    [:before, :after, :around].each do |callback|
      define_method "#{callback}_process" do |*names, &blk|
        _insert_callbacks(names, blk) do |name, options|
          set_callback(:process, callback, name, options)
        end
      end

      define_method "prepend_#{callback}_process" do |*names, &blk|
        _insert_callbacks(names, blk) do |name, options|
          set_callback(:process, callback, name, options.merge(:prepend => true))
        end
      end

      define_method "skip_#{callback}_process" do |*names|
        _insert_callbacks(names) do |name, options|
          skip_callback(:process, callback, name, options)
        end
      end
    end
  end
end

class Processor

  def execute(method)
    self.process_name = method
    process(method)
  end

  def process(method)
    send(method)
  end

  def process_name
    @process_name.to_s
  end

  def process_name=(process_name)
    @process_name = process_name
  end

  def payload
    @payload
  end

  def payload=(payload)
    @payload = payload
  end
end


class MyProcessor < Processor
  include MyCallbacks
  # set_callback :process, :before, :first
  before_process :first, if: proc {process_name == 'save'}

  def first
    p 'before first'
  end

  def save
    p 'save'
  end

  def delete
    p 'delete'
  end

  def xx
    process_name == 'save'
  end
end

processor = MyProcessor.new
# processor.execute(:delete)
processor.execute(:save)