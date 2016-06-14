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

def insert_envelope(envelope, result)
  left, right = 0, result.size - 1
  while left <= right
    mid = (left + right) / 2
    if result[mid] >= envelope
      right = mid - 1
    else
      left = mid + 1
    end
  end

  if left == result.size
    result.push(target)
  else
    result[left] = target
  end
end

def max_envelopes(envelopes)
  result = []

  # 宽度一样的 高度最大的放在前面
  # 这样的好处是， 相同高度的信封被重复统计
  # example [[2,3], [5,8], [5,4], [6,5]]
  # 高度较小的4 可以把8替换
  # 这样只要下一次出现比4大的就说明宽度变大了, 以便获得更好的潜力
  s_envelopes = envelopes.sort do |x, y|
    if x[0] != y[0]
      x[0] <=> y[0]
    else
      y[1] <=> x[1]
    end
  end

  s_envelopes.each do |envelope|
    insert(envelope[1], result)
  end

  result.size
end

p max_envelopes([[2,3], [5,8], [5,4], [6,5]])
