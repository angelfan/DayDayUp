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
        sleep 2
        condition.signal
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

p Test.new.call # 2秒后返回10

# 不过这种协程用 Fiber 可读性更好
require 'fiber'

class Test2
  attr_accessor :response

  def initialize
    @thread = Fiber.new do
      self.response = 'fiber'
      sleep 2
      Fiber.yield
    end
  end

  def call
    @thread.resume
    response
  end
end


p Test2.new.call


class Test3
  attr_accessor :mutex, :fill_cv, :empty_cv, :consumer_count, :product_count, :value

  def initialize
    @mutex = Mutex.new
    @fill_cv = ConditionVariable.new
    @empty_cv = ConditionVariable.new
    @consumer_count = 3
    @product_count = 0
    @value = nil
  end

  def call
    @arr = [1,2,3,4]
    @arr_mutex = []
    producer = Thread.new do
      @arr.each do |a|
        mutex.synchronize do
          while product_count > 0
            empty_cv.wait mutex
          end
          @value = a
          self.product_count = consumer_count
          fill_cv.broadcast
        end
      end
    end

    consumers = consumer_count.times.map do
      Thread.new do
        while producer.alive?
          mutex.synchronize do
            while product_count == 0
              fill_cv.wait mutex
            end
            @arr_mutex << @value
            self.product_count -= 1
            empty_cv.signal
          end
        end
      end
    end


    consumers.each &:join
    @arr_mutex
  end
end


p Test3.new.call
