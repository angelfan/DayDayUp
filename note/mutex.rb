require "bunny"
require "thread"

class Test
  attr_accessor :response
  attr_reader :mutex, :condition

  def initialize
    @mutex      = Mutex.new
    @condition = ConditionVariable.new

    Thread.new {
      mutex.synchronize {
        self.response = 10
        condition.signal
        sleep 5
      }
    }
  end

  def call
    Thread.new {
      mutex.synchronize {
        condition.wait(mutex)
      }
    }.join

    response
  end
end

# RabbitMQ的RPC依赖该方法实现
Test.new.call # 5秒后返回10