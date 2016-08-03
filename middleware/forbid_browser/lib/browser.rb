# coding: utf-8

class Browser
  attr_reader :name, :name_reg

  def initialize(name)
    @name = name.downcase
    @name_reg = Regexp.new(@name)
  end

  def forbid?(user_agent)
    user_agent.downcase =~ name_reg
  end
end
