# coding: utf-8

# 状态之间存在联系， 而策略模式之间的各种策略是没有联系的

# 状态模式和策略模式很类似，
# 不同的是状态模式的状态在其内部是有可能被改变的，
# 而策略模式是人为的去制定一种具体的实现方式
# 实例： 电灯的开关

# class Light
#   def initialize
#     @switch = Switch.new
#   end
#
#   def press_switch
#     @switch.press
#   end
# end
#
# class Switch
#   def initialize
#     @status = @status || On.new
#   end
#
#   def press
#     @status.press
#     @status = @status.change
#   end
# end
#
# class On
#   def press
#     p 'k'
#   end
#   def change
#     Off.new
#   end
# end
#
#
# class Off
#   def press
#     p 'g'
#   end
#   def change
#     On.new
#   end
# end
#
#
#
#
# l = Light.new
# l.press_switch
# l.press_switch
# l.press_switch
# l.press_switch

# 开关：抽象状态
class Switch
  def press(light)
    if light.switch.class == self.class
      light.switch = On.new
      press(light)
    else
      light.switch.press(light)
    end
  end
end

# 打开：具体状态
class On < Switch
  def press(con)
    puts 'on'
    con.switch = Off.new
  end
end

# 关闭：具体状态
class Off < Switch
  def press(con)
    puts 'off'
    con.switch = On.new
  end
end

# 灯：上下文环境
class Light
  attr_accessor :switch

  def initialize
    @switch = Switch.new
  end

  # def change_state(s)
  #   @switch = s
  # end

  def press
    @switch.press(self)
  end
end

c = Light.new
c.press
c.press
c.press
c.press
c.press
c.press
