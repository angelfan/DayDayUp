MY_DATA=[['slashdot','USA','yes',18,'None'],
         ['google','France','yes',23,'Premium'],
         ['digg','USA','yes',24,'Basic'],
         ['kiwitobes','France','yes',23,'Basic'],
         ['google','UK','no',21,'Premium'],
         ['(direct)','New Zealand','no',12,'None'],
         ['(direct)','UK','no',21,'Basic'],
         ['google','USA','no',24,'Premium'],
         ['slashdot','France','yes',19,'None'],
         ['digg','USA','no',18,'None'],
         ['google','UK','no',18,'None'],
         ['kiwitobes','UK','no',19,'None'],
         ['digg','New Zealand','yes',12,'Basic'],
         ['slashdot','UK','no',21,'None'],
         ['google','UK','yes',18,'Basic'],
         ['kiwitobes','France','yes',19,'Basic']].freeze

class DecisionNode
  attr_accessor :col, :value, :result, :tb, :fb

  def initialize(col=-1, value=nil, result=nil, tb=nil, fb=nil)
    @col = col
    @value = value
    @result = result
    @tb = tb
    @fb = fb
  end

  def divideset(rows, column, value)
    if value.is_a?(Integer) || value.is_a?(Float)
      split_function = lambda { |row| row[column] >= value }
    else
      split_function = lambda { |row| row[column] >= value }
    end

    set1 = rows.select { |row| split_function.call(row) }
    set2 = rows.select { |row| !split_function.call(row) }
    [set1, set2]
  end

  def uniquecounts(rows)
    rows.each_with_object(Hash.new(0)) do |row, results|
      r = row[row.size-1]
      results[r]+=1
    end
  end

  def giniimpurity(rows)
    total= rows.size
    counts = uniquecounts(rows)
    imp = 0
    for k1 in counts:
      p1=counts[k1]/total
      for k2 in counts
        if k1==k2
          p2=counts[k2]/total
          imp+=p1*p2
    imp
  end
end

# p DecisionNode.new.divideset(MY_DATA, 2, 'yes')
p DecisionNode.new.uniquecounts(MY_DATA)


# def giniimpurity(rows):
#     total=len(rows)
# counts=uniquecounts(rows)
# imp=0
# for k1 in counts:
#   p1=float(counts[k1])/total
#   for k2 in counts:
#     if k1==k2: continue
#     p2=float(counts[k2])/total
#     imp+=p1*p2
#     return imp
