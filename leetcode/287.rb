# [1,2,3,2]
# https://leetcode.com/problems/find-the-duplicate-number/
#
# Given an array nums containing n + 1 integers where each integer is between
# 1 and n (inclusive), prove that at least one duplicate number must exist.
# Assume that there is only one duplicate number, find the duplicate one.
#
# Notes:
#
#     + You must not modify the array (assume the array is read only).
#     + You must use only constant, O(1) extra space.
#     + Your runtime complexity should be less than O(n2).
#     + There is only one duplicate number in the array, but it could be
#       repeated more than once.
#
# Credits:
#
#     Special thanks to @jianchao.li.fighter for adding this problem and
#     creating all test cases.

# https://boweihe.me/?p=1920
# http://keithschwarz.com/interesting/code/?dir=find-duplicate
# http://blog.csdn.net/monkeyduck/article/details/40083527
# http://blog.csdn.net/monkeyduck/article/details/50439840

# 假设可以改变数组
# 不断的将对应的数字放到对应的索引上
def find_duplicate_1(nums)
  # (0..(nums.size-1)) 代表索引位置
  (0..(nums.size-1)).to_a.each do |i|
    if nums[i] != i+1 # 判断这个位置的元素是否放到了正确的位置上
      # 如果没有 判断他的位置上是否已经有了正确的元素
      return nums[i] if nums[i]  == nums[nums[i] - 1]

      # 否则把元素放到正确的位置上
      swap(nums[nums[i] - 1], nums[i])
    end
  end
end


def find_duplicate_2(nums)
  fast, slow = nums[nums[0]],nums[0]

  while slow != fast
    fast = nums[nums[fast]]
    slow = nums[slow]
  end

  fast = 0

  while fast != slow
    slow = nums[slow]
    fast = nums[fast]

  end

  fast
end


# 以 1 2 3 4 5 5 6 7 为例
# 先设中间数为4
# 因为小于等于4的有4个
# 所以这个数肯定在 [5,7] 质检
# 中间数为6
# 同理 可以确定这个数的区间为 [5,6]
# 这样会求得下一次的区间应该为[5,5]
# 因为区间相等了 所以但会left 或者返回right 都可以
def find_duplicate_3(nums)
  n = nums.size - 1
  left, right = 1, n
  while left < right
    mid = (right + left)/2
    count = 0

    for i in 0..n do
      count += 1 if nums[i] <= mid
    end

    if count > mid
      right = mid
    else
      left = mid + 1;
    end
  end
  right
end

find_duplicate_1([1,3,3,4,2])
find_duplicate_2([1,2,3,4,2])
find_duplicate_3([1,2,3,4,5,5,6,7])


def test
  nums = [4,6,5,1,3,2,8,7,2]
  # nums = [1,2,3,4,5,5,6,7]
  fast = 0 # nums[1]
  slow = 0

  10.times.each do |time|
    p "第#{time}次"
    p "fast: #{fast}"
    p "slow: #{slow}"
    fast = nums[nums[fast]] # nums[5] nums[nums[5]]
    slow = nums[slow]
  end
end
