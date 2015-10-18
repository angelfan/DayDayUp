# —抽象策略角色： 策略类，通常由一个接口或者抽象类实现。
# —具体策略角色：包装了相关的算法和行为。
# —环境角色：持有一个策略类的引用，最终给客户端调用。

# 抽象策略
# 基于鸭子模型， 这里的抽象策略可以省略不写
class Output
  def output_report
    fail 'need overwrite'
  end
end

# 策略1
class HTMLFormatter < Output
  def output_report(title, text)
    puts '<html>'
    puts '    <head>'
    puts '        <title>' + title + '</title>'
    puts '    </head>'
    puts '    <body>'
    text.each do |line|
      puts "<p>#{line}</p>"
    end
    puts '    </body>'
    puts '</html>'
  end
end

# 策略2
class PlainTextFormatter < Output
  def output_report(title, text)
    puts '******** ' + title + ' ********'
    text.each do |line|
      puts line
    end
  end
end

# 环境
class Reporter
  attr_reader :title, :text
  attr_accessor :formater

  def initialize(formater)
    @title = 'My Report'
    @text = ['This is my report', 'Please see the report', 'It is ok']
    @formater = formater
  end

  # 可以把指向自己的引用传入策略中，这样做虽然简化了数据流动，但是增加了环境和策略之间的耦合
  def output_report
    @formater.output_report @title, @text
    # @formater.output_report self
  end
end

Reporter.new(HTMLFormatter.new).output_report
Reporter.new(PlainTextFormatter.new).output_report

# 再来回头说模板方法模式，
# 模板方法模式，是寻找共同，然后提取出模板
# 策略模式，是将不同的方法封装成一个策略，这些策略不尽相同，难以提取共同部分

# 如果策略足够简单，仅有一个方法，那么可以通过代码块传递
class ProcReporter
  attr_reader :title, :text
  attr_accessor :formatter

  def initialize(&formatter)
    @title = 'My Report'
    @text = ['This is my report', 'Please see the report', 'It is ok']
    @formatter = formatter
  end

  # 可以把指向自己的引用传入策略中，这样做虽然简化了数据流动，但是增加了环境和策略之间的耦合
  def output_report
    @formatter.call self
  end
end

report_html = ProcReporter.new do |context|
  puts '<html>'
  puts '    <head>'
  puts '        <title>' + context.title + '</title>'
  puts '    </head>'
  puts '    <body>'
  context.text.each do |line|
    puts "<p>#{line}</p>"
  end
  puts '    </body>'
  puts '</html>'
end
p report_html.output_report

# 一个简单的轻量级策略对象的好例子
a = %w(1 12 123 6234567 3 13)
p a.sort
p a.sort { |a, b| a.length <=> b.length }
