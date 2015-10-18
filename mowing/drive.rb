# coding: utf-8

# 驱动类，在某一个方向上进行移动
class Driver
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def location
    [@x, @y]
  end

  def move(direction, step = 1)
    validate(direction)
    send("move_to_#{direction.downcase}", step)
  end

  private
  def move_to_n(step)
    @y += step
  end

  def move_to_w(step)
    @x -= step
  end

  def move_to_s(step)
    @y -= step
  end

  def move_to_e(step)
    @x += step
  end

  def validate(element)
    unless %w(N W S E).include?(element)
      raise '方向设置不在: N W S W 中'
    end
  end
end
