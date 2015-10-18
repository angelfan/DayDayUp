# coding: utf-8
# 故事从面试开始：

class Receiver
  attr_reader :name
  def initialize(name)
    @name = name
  end

  # 当有人来啦
  def person_come
    '有人来啦, 我去接待'
  end
end
lucy = Receiver.new('lucy')
# 其次我们有一个面试官lily
class Interviewer
  attr_reader :name
  def initialize(name)
    @name = name
  end

  # 当有人来啦
  def person_come
    '有人来啦, 我去面试'
  end
end

# 最初当有人来面试的时候可以像下面这样
class NewPerson
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def come
    puts '我来面试了'
    puts Receiver.new('lucy').person_come
    puts Interviewer.new('lily').person_come
  end
end

NewPerson.new('jack').come
