# #encoding:utf-8

# 观察者模式（有时又被称为发布/订阅模式）是软件设计模式的一种。
# 在此种模式中，一个目标对象管理所有相依于它的观察者对象，并且在它本身的状态改变时主动发出通知。
# 这通常透过呼叫各观察者所提供的方法来实现。

# 实现观察者模式的时候要注意，观察者和被观察对象之间的互动关系不能
# 体现成类之间的直接调用，否则就将使观察者和被观察对象之间紧密的耦合起来，
# 从根本上违反面向对象的设计的原则。无论是观察者“观察”观察对象，
# 还是被观察者将自己的改变“通知”观察者，都不应该直接调用。

module Subject
  # 初始化一个存放观察者的数组
  def initialize
    puts 'subject initialize..'
    @observers = []
  end

  # 将观察者塞入该数组(在本文中，这些观察者实际上是一个实例化的类)
  def add_observer(ob)
    @observers << ob
  end

  # 将观察者从数组中删除
  def delete_observer(ob)
    @observers.delete ob
  end

  # 通知观察者
  # 1.遍历数组中所有的观察者
  # 2.执行该观察者的update方法， 将self作为参数传递，这里的self是被观察者（被观察者类的是实例化）
  def notify_observers
    @observers.each do |ob|
      ob.update self
    end
  end
end

# 被观察者
class Employee
  include Subject
  attr_reader :name, :title
  attr_reader :salary

  def initialize(name, title, salary)
    super()
    puts 'Employee initialize..'
    @name = name
    @title = title
    @salary = salary
  end

  # 调用salary=的时候通知观察者
  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end

# 观察者
class Taxman
  def update(obj)
    puts "Taxman： #{obj.name} now has a salary of #{obj.salary}"
  end
end

# 观察者
class Employer
  def update(obj)
    puts "Employer： #{obj.name} now has a salary of #{obj.salary}"
  end
end

jack = Employee.new('jack', 'prgramer', 3000)
jack.add_observer(Taxman.new)
jack.add_observer(Employer.new)
jack.salary = 3001
jack.salary = 3002
