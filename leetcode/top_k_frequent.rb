# https://leetcode.com/problems/top-k-frequent-elements/
# 统计出现次数 然后按照出现次数进行排序
def top_k_frequent_low(nums, k)
  nums.sort!
  arr = []
  nums.each_with_index do |n, i|
    if i == 0
      arr = [[1, n]]
    else
      if n == nums[i - 1]
        arr[-1] = [arr.dup[-1][0] + 1, n]
      else
        arr << [1, n]
      end
    end
  end

  arr.sort { |x, y| y[0] <=> x[0] }[0..k - 1].map { |a| a[1] }
end

def top_k_frequent(nums, k)
  num_hash = Hash.new(0)
  nums.each.each do |n|
    num_hash[n] += 1
  end

  temp = []
  num_hash.each do |k, v|
    insert([k, v], temp)
  end
  temp[0..k - 1].map { |v| v[0] }
end

def insert(n, temp)
  # 【元素, 出现次数】
  left = 0
  right = temp.size - 1
  while left <= right
    mid = (left + right) / 2
    if temp[mid][1] >= n[1]
      left = mid + 1
    else
      right = mid - 1
    end
  end

  if left == temp.size
    temp.push(n)
  else
    temp.insert(left, n)
  end
end

def top_k_frequent_less(nums, k)
  m = Hash.new { |hash, key| hash[key] = 0 }
  nums.each { |n| m[n] -= 1 }
  m.sort_by(&:last).take(k).map(&:first)
end
