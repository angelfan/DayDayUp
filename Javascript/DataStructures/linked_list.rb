class Direction
  attr_accessor :next, :prev

  def initialize(element)
    @element = element
    @next = nil
    @prev = nil
  end
end

class Space
  attr_reader :header

  def initialize
    @header = nil
    @length = 0
  end

  def find(item)
    curr_direction = @header
    pos = 0
    unless @header.nil?
      while curr_direction.element != item && pos <= @length
        curr_direction = curr_direction.next
        pos += 1
      end
      curr_direction
    end
  end

  def insert(element, item = nil)
    if @length == 0
      @header = Direction.new(element)
      @header.next = @header
      @header.prev = @header
    else
      new_direction = Direction.new(element)
      current = find(item)
      new_direction.next = current.next # 插入节点的后继变成新节点的后继
      current.next.prev = new_direction
      current.next = new_direction # 插入节点的后继变成新节点
      new_direction.prev = current # 新节点的前驱变成插入节点
    end
  end
end

space = Space.new
space.insert('a')
a = Direction.new('a')
space.insert('b', a)
p space
