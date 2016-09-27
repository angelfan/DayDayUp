#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 有关 Fiber 的解释: (按照数据流的方向分为两部分)

# 在 `主线程' 中使用 resume 方法来启动(或继续执行)一个 `纤程'.
# 1. 第一次调用 fiber.resume, 会启动一个纤程,
#    如果 resume 调用时提供了实参, 会作为代码块形参传入代码块.
# 2. 如果非第一次调用 fiber.resume, 即, `恢复' 一个纤程, 会做两件事:
#    - 从上次离开纤程的那个位置(调用 Fiber.yield 离开纤程的那个位置), 恢复纤程的执行.
#    - 如果 resume 调用时提供了实参, 会传入 block, 作为 Fiber.yield 的返回值.

# 在纤程代码块中, 使用 Fiber.yield 暂停一个纤程, 并返回一个值给 resume 方法.
# 1. 如果存在 Fiber.yield VALUE, 则返回 VALUE 给 resume 方法, 不提供参数返回 nil.
# 2. 如果没有 Fiber.yield 语句, 返回 block 的返回值.

# 换个角度来理解纤程: Fiber 就是将 `Block' 和 `调用 Block 的代码' 分在两个线程中执行,
# 并且指定了线程的切换条件而已, 如果在 Fiber 的 block 中, 从来不指定 Fiber.yield,
# 就和在同一个线程中通过一个 block 来执行一段代码, 不存在任何区别了.
# 只要你真正的理解了Ruby 中的 block, 就基本上理解了纤程, 只是稍稍复杂一点点.

require 'eventmachine'
require 'em-http'
require 'fiber'

do_request_fiber = Fiber.new do
  puts "Setting up HTTP request #1"

  f = Fiber.current
  http = EventMachine::HttpRequest.new('http://www.google.com/').get :timeout => 10

  http.callback { EM.stop; f.resume(http) }
  http.errback { EM.stop; f.resume(http) }

  puts "Fetched page #1: #{Fiber.yield.response_header.status}"
end

EventMachine.run do
  do_request_fiber.resume
end

# 流程分析:

# 1. l39, 在 EM.run 中, 通过 do_request_fiber.resume 启动一个新的 fiber.
# 2. l27, puts "Setting up HTTP request #1".
# 3. l29, 在 block 中获取当前 fiber 对象到 f.
# 4. l30, 向 www.google.com 发送一个 get 请求. 然后立即返回.
# 5. l32-33, 为刚才的那个请求, 注册 callback 和 errback 两个 callback,
#    当 http 被正常响应时, callback 被执行, 否则 errback 被执行.
#    注意, 我这里故意将 EventMachine.stop 写在第一行, 这会有一个错觉,
#    callback 刚开始执行就 stop 了, 其实不是这样, 稍后有解释.
# 6. l35, 执行 puts "Fetched ...",  当执行到 Fiber.yield.response_header.status 时,
#    只执行了一半, 即: Fiber.yield, 就被 yield 回了 EM 主线程, .response_header.status 根本没有被执行.
# 7. EM 主线程 loop 仍在继续. 不过, 这并不会让 resume 方法被重新调用, 我觉得这是最大的一个猫腻了.
#    因为 EM.run 中的所有代码, 在 EM 初始化之后, Reactor 循环开始之前, 被执行的.
# 8. 在经过 n 个 EM loop 之后, 终于 http.callback 激发条件被满足(www.google.com 发回了响应),
#    此时, callback 中的代码 `在主线程中' 被执行.
# 9. l32, 通过 EM.stop 注册在下一轮 loop 时, 终止 EM 的 reactor 循环. 本轮仍会继续, 这回答了 #5 的问题.
# 10. l32, 调用 f.resume(http), 恢复之前暂停的纤程 `从暂停位置' 继续向后执行,
#     并且传递 http 对象给 Fiber.yield.
# 11. 回到纤程中, 在 Fiber.yield(它的值是: http 对象)之上调用 response_header.status. puts 结果.
# 12. 在下一个 loop 中, EM 的 Reactor 循环被终止, EM 退出.