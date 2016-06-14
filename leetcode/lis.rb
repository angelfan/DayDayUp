def insert(n, temp)
  # 这边只是求潜力最大的数组, 并不是真正的LIS
  # 比如[1,3,7,9,5] 最终返回的数组是[1,3,5,9]
  # 说他潜力大, 是因为 假设原数组是[1,3,7,9,5,6,8]
  # 他可以返回 [1, 3, 5, 6, 8]
  left, right = 0, temp.size - 1
  while left <= right
    mid = (left + right) / 2
    if temp[mid] >= n
      right = mid - 1
    else
      left = mid + 1
    end
  end

  if left == temp.size
    temp.push(n)
  else
    temp[left] = n
  end
end

def max(nums)
  temp = []
  nums.each do |n|
    insert(n, temp)
  end
  temp.size
end

p max([1,3,7,9,5,6,8])
