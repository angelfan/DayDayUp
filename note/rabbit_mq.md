# RabbitMQ

## Publisher(Producer)
```ruby
class Publisher
  # In order to publish message we need a exchange name.
  # Note that RabbitMQ does not care about the payload -
  # we will be using JSON-encoded strings
  def self.publish(exchange, message = {})
    x = channel.fanout("publisher.#{exchange}")
    x.publish(message.to_json)
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
# 对于OS来说，建立和关闭TCP连接是有代价的，频繁的建立关闭TCP连接对于系统的性能有很大的影响，而且TCP的连接数也有限制，
# 这也限制了系统处理高并发的能力。但是，在TCP连接中建立Channel是没有上述代价的。对于Producer或者Consumer来说，
# 可以并发的使用多个Channel进行Publish或者Receive
```

```ruby
Publisher.publisher('test', 'Hello, RabbitMQ')
# RabbitMQ Exchanges 中可以看到它 不过尚未绑定
```

## Subscriber(Consumer)

```ruby
class SubscriberWorker
  include Sneakers::Worker
  from_queue "subscriber.test", env: nil


  def work(raw_post)
    process raw_post
    ack! # we need to let queue know that message was received
  end
end
```
默认情况下，如果Message 已经被某个Consumer正确的接收到了，那么该Message就会被从queue中移除。当然也可以让同一个Message发送到很多的Consumer。
如果一个queue没被任何的Consumer Subscribe（订阅），那么，如果这个queue有数据到达，那么这个数据会被cache，不会被丢弃。当有Consumer时，这个数据会被立即发送到这个Consumer，这个数据被Consumer正确收到时，这个数据就被从queue中删除。
那么什么是正确收到呢？通过ack。每个Message都要被acknowledged（确认，ack）。我们可以显示的在程序中去ack，也可以自动的ack。如果有数据没有被ack，那么：
RabbitMQ Server会把这个信息发送到下一个Consumer。
如果这个app有bug，忘记了ack，那么RabbitMQ Server不会再发送数据给它，因为Server认为这个Consumer处理能力有限。
而且ack的机制可以起到限流的作用（Benefitto throttling）：在Consumer处理完成数据后发送ack，甚至在额外的延时后发送ack，将有效的balance Consumer的load。
当然对于实际的例子，比如我们可能会对某些数据进行merge，比如merge 4s内的数据，然后sleep 4s后再获取数据。特别是在监听系统的state，我们不希望所有的state实时的传递上去，而是希望有一定的延时。这样可以减少某些IO，而且终端用户也不会感觉到。



## bind
```ruby
conn = Bunny.new # 默认配置 以guest用户连接本地RabbitMQ
conn.start

ch = conn.create_channel
# Publisher端的exchange
x = ch.fanout("publisher.test")

# Subscriber获得消息的队列
# durable
queue = ch.queue("subscriber.test", durable: true)

# 告诉exchange这条消息要路由到那个队列
queue.bind("publisher.test")

conn.close
```

### 资源
+ [Rails 中用 RabbitMQ 做消息队列 [译]](https://ruby-china.org/topics/22332)
+ [RabbitMQ消息队列](http://blog.csdn.net/anzhsoft/article/details/19563091)
+ [Tutorials](https://www.rabbitmq.com/getstarted.html)
+ [Tutorials翻译](http://liuvblog.com/tags/#RabbitMQ)
