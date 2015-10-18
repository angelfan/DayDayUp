# coding: utf-8
# 执行该文件启动
require File.dirname(__FILE__) + '/work' # 割草机
class GetConsole
  attr_reader :meadow, :mower, :route

  def initialize
    @meadow = gets.split(' ').map(&:to_i)
    @mower = gets.split(' ')
    @route = gets.split('')
    @route.pop # 按回车后 数组中最后一个元素是换行符
  end
end

console = GetConsole.new

work = Work.new
work.init_meadow(console.meadow[0], console.meadow[1])
work.init_mower(console.mower[0].to_i, console.mower[1].to_i, console.mower[2])

work.start(console.route)
