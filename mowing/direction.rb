# coding: utf-8

# position node
class Node
  attr_reader :element
  attr_accessor :left, :right

  def initialize(element)
    @element = element
    @left = nil
    @right = nil
  end
end

# direction control (similar to the steering wheel)
class DirectionCtrl
  attr_accessor :direction

  def initialize(direction)
    validate direction

    @direction = direction

    @north = Node.new('N')
    @south = Node.new('S')
    @west = Node.new('W')
    @east = Node.new('E')

    @node_count = 4

    @north.left = @west
    @north.right = @east

    @south.left = @east
    @south.right = @west

    @west.left = @south
    @west.right = @north

    @east.left = @north
    @east.right = @south
  end

  # get position node
  def get_node(item)
    validate item
    pos = 0
    current_node = @north
    while current_node.element != item || pos < 5
      pos += 1
      current_node = current_node.left
    end
    current_node
  end

  def turn_left
    @direction = get_node(direction).left.element
  end

  def turn_right
    @direction = get_node(direction).right.element
  end

  private

  def validate(element)
    fail '方向设置不在: N W S W 中' unless %w(N W S E).include?(element)
  end
end
