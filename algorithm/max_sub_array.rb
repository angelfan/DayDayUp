# 最大子数组问题
# 要么在左边 左边最最优解
# 要么在右边 右边最优解
# 要么跨越了两边 左边最最优解 + 右边最优解 + mid

# 求跨越两边情况下的和
def find_max_crossing_sub_array(array, low, mid, high)
  left_sum = -10000
  l_sum = 0
  max_left = 0
  (low..mid).to_a.reverse.each do |i|
    l_sum  += array[i]
    if l_sum > left_sum
      left_sum = l_sum
      max_left = i
    end
  end


  right_sum = -10000
  r_sum = 0
  max_right = 0
  (mid+1..high).to_a.each do |j|
    r_sum += array[j]
    if r_sum > right_sum
      right_sum = r_sum
      max_right = j
    end
  end

  [max_left, max_right, left_sum + right_sum]
end

# 递归版本
def find_max_sub_array(array, low, high)
  return [low, high, array[low]] if low == high

  mid = (low + high) / 2
  left_low, left_high, left_num = find_max_sub_array(array, low, mid)
  right_low, right_high, right_num = find_max_sub_array(array, mid+1, high)
  c_low, c_high, c_num = find_max_crossing_sub_array(array, low, mid, high)

  if left_num >= right_num && left_num >= c_num
    [left_low, left_high, left_num]
  elsif right_num >= left_num && right_num >= c_num
    [right_low, right_high, right_num ]
  else
    [c_low, c_high, c_num]
  end
end

array = [13, -3, -15, 20, -3, -16, -23, 18, 20, -7, 12, -5, -2211, 1511, -4, 7]
p find_max_sub_array(array, 0, array.size - 1)