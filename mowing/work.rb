# coding: utf-8
require File.dirname(__FILE__)+'/direction'
require File.dirname(__FILE__)+'/drive'
require File.dirname(__FILE__)+'/meadow'
require File.dirname(__FILE__)+'/mower'

# 工作类需要知道判断割草路径的合法性， 以及割草路径是否超过范围
# 工作类
class Work
  attr_reader :meadow, :mower, :error_msg

  def initialize
    @meadow = nil
    @mower = nil
    @error_msg = []
  end

  def init_meadow(meadow_x, meadow_y)
    @meadow = Meadow.new(meadow_x, meadow_y)
  end

  def init_mower(mower_x, mower_y, mower_direction)
    validate_point(mower_x, mower_y, mower_direction)

    unless @error_msg.any?
      @mower = Mower.new(mower_x, mower_y, mower_direction)
    end
  end

  def start(route)
    validate_route(route)

    if @error_msg.any?
      puts @error_msg
    else
      if @meadow && @mower
        @mower.start(route)
        puts @mower.location
      else
        puts '必须初始化一块草地和一个割草机'
      end
    end
  end

  private
  def validate_route(route)
    unless @error_msg.any?
      if route.all? { |rot| %w(L M R).include? rot }
        #  不能通过割草机执行后的坐标来验证， 只能通过模拟测试路径的合法性  TODO: 割草机惰性工作， 先探寻路径， 如果合法则按照之前探寻的结果来执行
        direction_ctrl = DirectionCtrl.new(@mower.direction)
        drive = Driver.new(@mower.x, @mower.y)
        route.each do |rot|
          if rot == 'L'
            direction_ctrl.turn_left
          end

          if rot == 'R'
            direction_ctrl.turn_right
          end

          if rot == 'M'
            drive.move(direction_ctrl.direction)
            if drive.x < 0 || drive.x > @meadow.x || drive.y < 0 || drive.y > @meadow.y
              @error_msg << '割草路径超出范围'
              return @error_msg
            end
          end
        end
      else
        @error_msg << '割草路径不合法'
      end
    end
  end

  def validate_point(x, y, direction)
    if x < 0 || x > @meadow.x || y < 0 || y > @meadow.y
      @error_msg << '割草机开始坐标不能超出草地范围'
    end
    unless %w(N W S E).include?(direction)
      @error_msg << '割草机面朝方向必须是东(E)西(W)南(S)北(N)'
    end
  end

end