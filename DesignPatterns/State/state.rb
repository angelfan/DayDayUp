# 抽象状态
class State
  def handle(con)
    if con.s.class == self.class
      con.s = Nonestate.new
      handle(con)
    else
      con.s.handle(con)
    end
  end
end

# 具体状态
class Nonestate < State
  def handle(con)
    puts 'in Nonestate'
    con.s = Astate.new
  end
end

class Astate < State
  def handle(con)
    puts 'in Astate'
    con.s = Bstate.new
  end
end

class Bstate < State
  def handle(con)
    puts 'in Bstate'
    con.s = Astate.new
  end
end

# 上下文环境
class Content
  attr_accessor :s

  def initialize
    @s = State.new
  end

  def change_state(s)
    @s = s
  end

  def request
    @s.handle(self)
  end
end

c = Content.new
c.request
c.request
c.request
c.request
c.request
c.request
