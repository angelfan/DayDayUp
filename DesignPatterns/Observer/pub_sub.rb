# #encoding:utf-8
# 观察者模式(ruby)的使用例子， ruby提供了observer更方便我们实现观察者模式
require 'observer'

# 被观察者My
class MyObservable
  include Observable
  attr_reader :name, :title, :salary

  def initialize(name, title, salary)
    super()
    puts 'Employee initialize..'
    @name = name
    @title = title
    @salary = salary
  end

  def name=(new_name)
    @name = new_name
    changed
    notify_observers(name)
  end

  def title=(new_title)
    @title = new_title
    changed
    notify_observers(title, title)
  end

  def salary=(new_salary)
    @salary = new_salary
    changed
    notify_observers(s: 1, m: 2, a: 3)
  end
end

# 观察者A
class AObserver
  # update方法名是必须的要有的
  def update(*arg)
    puts "AObserver 被通知了#{arg}"
  end
end

# 观察者B
class BObserver
  # update方法名是必须的要有的
  def update(*arg)
    puts "BObserver 被通知了#{arg} "
  end
end

class Angel
  def my_updata(*_arg)
    puts 'angel is OK'
  end
end

# 观察者初始化
observer_a = AObserver.new
observer_b = BObserver.new
observer_my = Angel.new

# 被观察者初始化
obj = MyObservable.new(1, 2, 3)

# 添加监视对象
obj.add_observer(observer_a)
obj.add_observer(observer_b)
obj.add_observer(observer_my, :my_updata)

# 被观察者改变了 ->这段代码 必须有 不然无法通知到观察者
obj.changed

# 通知观察者
obj.salary = 2
obj.salary = 2
