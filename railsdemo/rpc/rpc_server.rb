class RpcWorker
  include Sneakers::Worker
  # This worker will connect to "dashboard.posts" queue
  # env is set to nil since by default the actuall queue name would be
  # "dashboard.posts_development"
  from_queue "rpc_test", env: nil

  # work method receives message payload in raw format
  # in our case it is JSON encoded string
  # which we can pass to RecentPosts service without
  # changes
  def work_with_params(msg, delivery_info, metadata)
    delivery_info.channel.default_exchange.publish(fib(msg.to_i).to_s,
                                                   routing_key: metadata.reply_to,
                                                   correlation_id: metadata.correlation_id)
    ack!
  end

  def fib(n)
    case n
      when 0 then
        0
      when 1 then
        1
      else
        fib(n - 1) + fib(n - 2)
    end
  end
end

# ----------
require "bunny"

conn = Bunny.new
conn.start

ch = conn.create_channel

class FibonacciServer

  def initialize(ch)
    @ch = ch
  end

  def start(queue_name)
    @q = @ch.queue(queue_name)
    @x = @ch.default_exchange

    @q.subscribe(:block => true) do |delivery_info, properties, payload|
      n = payload.to_i
      r = self.class.fib(n)

      @x.publish(r.to_s, :routing_key => properties.reply_to, :correlation_id => properties.correlation_id)
    end
  end

  def self.fib(n)
    case n
      when 0 then
        0
      when 1 then
        1
      else
        fib(n - 1) + fib(n - 2)
    end
  end
end

begin
  server = FibonacciServer.new(ch)
  " [x] Awaiting RPC requests"
  server.start("rpc_queue")
rescue Interrupt => _
  ch.close
  conn.close
end