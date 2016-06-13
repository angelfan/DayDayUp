class BinarySearchTreeNode < Struct.new(:value)
  attr_accessor :left, :right
  attr_writer :count, :lcount

  def count
    @count ||= 1
  end

  def lcount
    @lcount ||= 0
  end
end


class BinarySearchTree
  def initialize
    @root = nil
  end

  def insert(value)
    if @root.nil?
      @root = BinarySearchTreeNode.new(value)
      return 0
    end

    node, order = @root, 0
    while true
      # p [node, value]
      if node.value > value
        node.lcount += 1
        if node.left
          node = node.left; next
        else
          node.left = BinarySearchTreeNode.new(value)
          return order
        end
      end

      if node.value < value
        order += node.lcount + node.count
        if node.right
          node = node.right; next
        else
          node.right = BinarySearchTreeNode.new(value)
          return order
        end
      end


      node.count += 1
      return order + node.lcount
    end
  end
end



# @param {Integer[]} nums
# @return {Integer[]}
def count_smaller(nums)
  tree = BinarySearchTree.new
  nums.reverse.map do |n|
    tree.insert(n)
  end.reverse
  # nums.reverse.map {|n| tree.insert(n) }.reverse
end

p count_smaller([5,5,3,2,1,6])

def merge(nums, from, to, pos, answer)
  if from >= to
    return
  end

  mid = (from + to) / 2
  merge(nums, from, mid, pos, answer)
  merge(nums, mid + 1, to, pos, answer)
  temp = Array.new(to - from + 1) { 0 }
  x = from
  y = mid + 1
  temp.each_with_index do |_v, i|
    if x > mid
      temp[i] = pos[y]
      y += 1
    elsif y > to
      temp[i] = pos[x]
      x += 1
    elsif nums[pos[x]] > nums[pos[y]]
      answer[pos[x]] += to - y + 1
      temp[i] = pos[x]
      x += 1
    else
      temp[i] = pos[y]
      y += 1
    end
  end

  temp.each_with_index do |_v, i|
    pos[i + from] = temp[i]
  end

end

def count_smaller_merge(nums)
  n = nums.size
  pos = Array.new(n) { 0 }.map.with_index{|_v, i| i}
  answer = Array.new(n) { 0 }
  merge(nums, 0, n-1, pos, answer)
  answer
end


class FenwickTree
  attr_accessor :n, :sums

  def initialize(n)
    @n = n
    @sums = Array.new(n + 1) { 0 }
  end

  def add(x, val)
    while x <= n
      sums[x] += val
      x += lowbit(x)
    end
  end

  def lowbit(x)
    x & -x
  end

  def sum(x)
    res = 0
    while x > 0
      res += sums[x]
      x -= lowbit(x)
    end
    res
  end
end

def count_smaller_tree(nums)
  idxes = {}
  nums.sort.each_with_index {|v, i| idxes[v] ||= i + 1}
  i_nums = nums.map {|n| idxes[n] }

  ft = FenwickTree.new(nums.size)
  ans = Array.new(nums.size)

  (0..(nums.size-1)).to_a.reverse.each do |i|
    ans[i] = ft.sum(i_nums[i] - 1)
    ft.add(i_nums[i], 1)
  end

  ans
end


p count_smaller_tree([9,3,5,7,1,9])

