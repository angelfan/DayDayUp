# 将不同的表现原子化， 然后逐渐按需包装

class Tree
  def initialize
    puts 'Make a normal tree'
  end

  def decorate
    0
  end
end

class RedBalls < Tree
  def initialize(tree)
    @parent = tree
  end

  def decorate
    @parent.decorate + 1
  end
end

class BlueBalls < Tree
  def initialize(tree)
    @parent = tree
  end

  def decorate
    @parent.decorate + 1
  end
end

class Angel < Tree
  def initialize(tree)
    @parent = tree
  end

  def decorate
    @parent.decorate + 3
  end
end

p Tree.new
tree = Angel.new(BlueBalls.new(RedBalls.new(Tree.new)))
p tree.decorate
