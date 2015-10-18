# step1
class Result
  def total(*scores)
    percentage_calculation(*scores)
  end

  private

  def percentage_calculation(*scores)
    puts "Calculation for #{scores.inspect}"
    scores.inject { |sum, n| sum + n } * (100.0 / 80.0)
  end
end

r = Result.new
puts r.total(5, 10, 10, 10, 10, 10, 10, 10)
puts r.total(5, 10, 10, 10, 10, 10, 10, 10)
puts r.total(10, 10, 10, 10, 10, 10, 10, 10)
puts r.total(10, 10, 10, 10, 10, 10, 10, 10)

# step 2
class Result
  def total(*scores)
    percentage_calculation(*scores)
  end

  private

  def percentage_calculation(*scores)
    puts "Calculation for #{scores.inspect}"
    scores.inject { |sum, n| sum + n } * (100.0 / 80.0)
  end
end

class MemoResult < Result
  def initialize
    @mem = {}
  end

  def total(*scores)
    if @mem.key?(scores)
      @mem[scores]
    else
      @mem[scores] = super
    end
  end
end

r = MemoResult.new
puts r.total(5, 10, 10, 10, 10, 10, 10, 10)
puts r.total(5, 10, 10, 10, 10, 10, 10, 10)
puts r.total(10, 10, 10, 10, 10, 10, 10, 10)
puts r.total(10, 10, 10, 10, 10, 10, 10, 10)
