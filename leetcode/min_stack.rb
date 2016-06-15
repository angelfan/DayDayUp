class MinStack
  attr_accessor :stack, :min_stack

  def initialize
    @stack = []
    @min_stack = []
  end

  def push(x)
    stack.push(x)
    min_stack.push(x) if min_stack.empty? || min_stack[-1] >= x
  end

  def pop
    x = stack.pop
    min_stack.pop if min_stack[-1] == x
    x
  end

  def top
    stack[-1]
  end

  def min
    min_stack[-1]
  end
end

stack = MinStack.new

stack.push(1)
stack.push(3)
stack.push(2)
stack.push(0)

p stack.min
stack.pop
p stack.min
