# 棋子
class Chessman
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def validate_move_rule
    fail 'Not yet implemented.'
  end
end

# 棋子： 马
class Horse < Chessman
  def validate_move_rule(original_coordinate, target_coordinate)
    valid = (original_coordinate.x ** 2 - target_coordinate.x ** 2 +
        original_coordinate.y ** 2 - target_coordinate.y ** 2) == 5
    fail MoveError unless valid
  end
end

# 棋子：炮
class Cannon < Chessman
  def validate_move_rule(original_coordinate, target_coordinate)
    valid = original_coordinate.x == target_coordinate.x || original_coordinate.y == target_coordinate.y
    fail MoveError unless valid
  end
end

class HorseMovingService
  # service会拿到已整改棋局， 要移动的目标棋子， 移动的目标坐标
  def initialize(chessboard, target_chessman, target_coordinate)
    @chessboard = chessboard
    @target_chessman = target_chessman
    @target_coordinate = target_coordinate
    @undo = {} # 记录目标棋子的初始位置 记录吃掉棋子的初始位置
  end

  def move
    # 验证马是否可以移动到目标位置
    # 1. validate_target_coordinate
    # 2. 判断目标是否有棋子 如果有棋子并且是对方的棋子 吃掉 call#eat
    @chessboard.undo_list << @undo
  end

  def validate_target_coordinate(target_coordinate)
    # 移动Chessboard验证坐标合法性的方法到这里
    @target_chessman.validate_move_rule(@target_chessman.condition, target_coordinate)
    # 验证是否被别了马腿

  end

  def validate_turns(chessman_color)
    # 验证是红方还是黑房的timing
  end


  def move
    # 棋盘上该棋子的坐标移动到目标坐标
    @undo[:move] = target
    @target_chessman.condition = target_coordinate
  end

  def eat
    # 棋盘上该棋子的坐标移动到目标坐标 并拿掉吃掉的棋子
    move
    # x: target_coordinate[:x]
    # y: target_coordinate[:y]
    @undo[:eat] = @chessboard.select(x, y)
    @chessboard.delete(x, y)
  end
end

class Chessboard
  attr_accessor :board, :undo_list

  MOVING_SERVICES = {
      'Horse' => HorseMovingService
      # ....
  }.freeze

  def initialize
    @undo_list = []
    @red_turns = true
    @board = []

    add(Horse.new('blank'), 1, 0)
    add(Horse.new('blank'), 7, 0)
    add(Cannon.new('blank'), 1, 2)
    add(Cannon.new('blank'), 7, 2)

    add(Horse.new('red'), 1, 9)
    add(Horse.new('red'), 7, 9)
    add(Cannon.new('red'), 1, 7)
    add(Cannon.new('red'), 7, 7)
  end

  def add(chessman, x, y)
    @board.push OpenStruct.new(chessman: chessman, coordinate: init_coordinate(x, y))
  end

  def delete(x, y)
    @board.reject! { |v| v.coordinate == init_coordinate(x, y) }
  end

  def select(x, y)
    @board.select { |v| v.coordinate == init_coordinate(x, y) }
  end


  # original_coordinate: {x: x, y: y}
  # target_coordinate: {x: x, y: y}
  def move(original_coordinate, target_coordinate)
    target_chessman = @board.select{ |v| v.coordinate == init_coordinate(original_coordinate[:x], original_coordinate[:y]) }.first
    moving_service = MOVING_SERVICES["#{target.chessman.class.name}"].new(self, target_chessman, target_coordinate)
    moving_service.move
  end

  def undo
    # undo_list.pop 然后恢复@board中的目标棋子
  end

  # def validate(target, target_coordinate)
  #   # validate_turns!(target.chessman.color)
  #   # validate_coordinate(target_coordinate)
  # end

  # def validate_coordinate(coordinate)
  #   # 验证坐标在棋盘是否合法
  # end

  # def validate_turns(chessman_color)
  #   return true if chessman_color == 'red' && @red_turns
  #   return true if chessman_color == 'blank' && !@red_turns
  #
  #   fail TurnsError
  # end

  # def validate_moving(target)
  #   MOVING_SERVICES["#{target.chessman.class.name}"].new(board, target)
  # end

  def init_coordinate(x, y)
    OpenStruct.new(x: x, y: y)
  end
end

class MoveError < StandardError; end
class TurnsError < StandardError; end

