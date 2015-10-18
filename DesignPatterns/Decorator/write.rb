class SimpleWriter
  def write(text)
    puts text
  end
end

module TimeStampingWriter
  def write(text)
    super ("#{Time.now}: #{text}")
  end
end

module NumberingWriter
  attr_reader :line_number

  def write(text)
    @line_number = 1 unless @line_number
    super("#{@line_number}: #{text}")
    @line_number += 1
  end
end

w = SimpleWriter.new
w.write('Hello')

w.extend(NumberingWriter)
w.write('Hello')
w.write('hi')
w.extend(TimeStampingWriter)
w.write('Hello')
w.extend(NumberingWriter)
w.write('Helloaa')
