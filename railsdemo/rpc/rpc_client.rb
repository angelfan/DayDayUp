require "bunny"
require "thread"


class Rpc
  # In order to publish message we need a exchange name.
  # Note that RabbitMQ does not care about the payload -
  # we will be using JSON-encoded strings
  class FibonacciClient
    attr_reader :reply_queue
    attr_accessor :response, :call_id
    attr_reader :lock, :condition

    def initialize(ch, server_queue)
      @ch             = ch
      @x              = ch.default_exchange

      @server_queue   = server_queue
      @reply_queue    = ch.queue("", :exclusive => true)

      @lock      = Mutex.new
      @condition = ConditionVariable.new
      that       = self

      @reply_queue.subscribe do |delivery_info, properties, payload|
        if properties.correlation_id == that.call_id
          that.response = payload.to_i
          that.lock.synchronize{that.condition.signal}
        end
      end
    end

    def call(n)
      self.call_id = self.generate_uuid

      @x.publish(n.to_s,
                 correlation_id: call_id,
                 reply_to: @reply_queue.name,
                 :routing_key    => @server_queue)
      lock.synchronize{condition.wait(lock)}
      response
    end

    protected

    def generate_uuid
      # very naive but good enough for code
      # examples
      "#{rand}#{rand}#{rand}"
    end
  end



  def self.publish(n)
    client = FibonacciClient.new(channel, 'rpc_test')
    client.call(n)
  end

  # 虚拟连接。它建立在上述的TCP连接中。数据流动都是在Channel中进行的
  def self.channel
    @channel ||= connection.create_channel
  end

  # We are using default settings here
  # The `Bunny.new(...)` is a place to
  # put any specific RabbitMQ settings
  # like host or port
  # 就是一个TCP的连接。Producer和Consumer都是通过TCP连接到RabbitMQ Server的
  def self.connection
    @connection ||= Bunny.new.tap do |c|
      c.start
    end
  end
end


# -------------
conn = Bunny.new(:automatically_recover => false)
conn.start

ch = conn.create_channel

class FibonacciClient
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(ch, server_queue)
    @ch = ch
    @x = ch.default_exchange

    @server_queue = server_queue
    @reply_queue = ch.queue("", :exclusive => true)

    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self

    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_i
        that.lock.synchronize { that.condition.signal }
      end
    end
  end

  def call(n)
    self.call_id = self.generate_uuid

    @x.publish(n.to_s,
               :routing_key => @server_queue,
               :correlation_id => call_id,
               :reply_to => @reply_queue.name)

    lock.synchronize { condition.wait(lock) }
    response
  end

  protected

  def generate_uuid
    # very naive but good enough for code
    # examples
    "#{rand}#{rand}#{rand}"
  end
end

client = FibonacciClient.new(ch, "rpc_queue")
puts " [x] Requesting fib(30)"
response = client.call(30)
puts " [.] Got #{response}"

ch.close
conn.close

