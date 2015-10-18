# coding: utf-8
# 不同的命令，共享同一种接口
class Command
  attr_reader :description, :array

  def initialize(description)
    @array = []
    @description = description
  end

  def execute
  end
end

class CreateWord < Command
  def initialize(content)
    super('create_word')
    @content = content
  end

  def execute
    @array << @content
    p 'create'
  end
end

class DeleteWord < Command
  def initialize(content)
    super('delete_word')
    @content = content
  end

  def execute
    @array.delete(@content)
    p 'delete'
  end
end

class CopyWord < Command
  def initialize(content)
    super('copy_word')
    @content = content
  end

  def execute
    p 'copy'
  end
end

class CompositeCommand < Command
  def initialize
    @commands = []
  end

  def add_command(cmd)
    @commands << cmd
  end

  def execute
    @commands.each(&:execute)
  end

  def description
    description = ''
    @commands.each { |cmd| description += cmd.description + "\n" }
    description
  end
end

cmds = CompositeCommand.new

cmds.add_command(CreateWord.new('hello'))
cmds.add_command(DeleteWord.new('hello'))
cmds.add_command(CopyWord.new('hello'))
puts cmds.description
cmds.execute
