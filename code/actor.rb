require 'fiber'

class Thread
  # 得到当前线程的调度器
  def __scheduler__
    @__internal_scheduler__ ||= FiberActor::Scheduler.new
  end
end

class Fiber
  # 得到当前Fiber的actor
  def __actor__
    @__internal_actor__
  end
end

module FiberActor
  class Scheduler
    def initialize
      @queue=[]
      @running=false
    end

    def run
      return if @running
      @running=true
      while true
        #取出队列中的actor并执行
        while actor=@queue.shift
          begin
            actor.fiber.resume
          rescue => ex
            puts "actor resume error,#{ex}"
          end
        end
        #没有任务，让出执行权
        Fiber.yield
      end
    end

    def reschedule
      if @running
        #已经启动，只是被挂起，那么再次执行
        @fiber.resume
      else
        #将当前actor加入队列
        self << Actor.current
      end
    end

    def running?
      @running
    end

    def <<(actor)
      #将actor加入等待队列
      @queue << actor unless @queue.last == actor
      #启动调度器
      unless @running
        @queue << Actor.current
        @fiber=Fiber.new { run }
        @fiber.resume
      end
    end
  end
end

module FiberActor
  class Actor
    attr_accessor :fiber
    #定义类方法
    class << self
      def scheduler
        Thread.current.__scheduler__
      end

      def current
        Fiber.current.__actor__
      end

      #启动一个actor
      def spawn(*args, &block)
        fiber=Fiber.new do
          block.call(args)
        end
        actor=new(fiber)
        fiber.instance_variable_set :@__internal_actor__, actor
        scheduler << actor
        actor
      end

      def receive(&block)
        current.receive(&block)
      end
    end

    def initialize(fiber)
      @mailbox=[]
      @fiber=fiber
    end

    #给actor发送消息
    def << (msg)
      @mailbox << msg
      #加入调度队列
      Actor.scheduler << self
    end

    def receive(&block)
      #没有消息的时候，让出执行权
      Fiber.yield while @mailbox.empty?
      msg=@mailbox.shift
      block.call( )
    end

    def alive?
      @fiber.alive?
    end
  end
end

FiberActor::Actor.spawn { puts 'hello world!' }

actor=FiberActor::Actor.spawn {
  FiberActor::Actor.receive { |msg| puts "receive #{msg}" }
}
actor << :test_message

pong=FiberActor::Actor.spawn do
  FiberActor::Actor.receive do |ping|
    #收到ping，返回pong
    ping << :pong
  end
end
FiberActor::Actor.spawn do
  #ping一下，将ping作为消息传递
  pong << FiberActor::Actor.current
  FiberActor::Actor.receive do |msg|
    #接收到pong
    puts "ping #{msg}"
  end
end
#resume调度器
FiberActor::Actor.scheduler.reschedule



