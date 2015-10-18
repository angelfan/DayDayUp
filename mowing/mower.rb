# coding: utf-8
require File.dirname(__FILE__)+'/direction' # 方向盘
require File.dirname(__FILE__)+'/drive' # 驱动

# 割草机类（含有两个组件，方向盘 和 驱动）
class Mower
  # 割草机类
  def initialize(x, y, direction)
    @direction_ctrl = DirectionCtrl.new(direction)
    @driver = Driver.new(x, y)
  end

  def l
    @direction_ctrl.turn_left
  end

  def r
    @direction_ctrl.turn_right
  end

  def m
    @driver.move(@direction_ctrl.direction)
  end

  def start(route)
    route.each do |med|
      public_send(med.downcase)
    end
  end

  def location
    "#{ @driver.x} #{ @driver.y} #{@direction_ctrl.direction}"
  end

  def x
    @driver.x
  end

  def y
    @driver.y
  end

  def direction
    @direction_ctrl.direction
  end

  # used for minitest
  def direction=(direction)
    @direction_ctrl.direction = direction
  end
end

