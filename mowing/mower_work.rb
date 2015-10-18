# coding: utf-8
require File.dirname(__FILE__) + '/mower'

console = GetConsole.new
console.validate

if console.error_msg.any?
  puts console.error_msg
else
  work = Work.new
  work.init_meadow(console.meadow[0], console.meadow[1])
  work.init_mower(console.mower[0], console.mower[1], console.mower[2])

  work.start(console.route)
end
