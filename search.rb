def search(arr, num)
  return if arr.size == 1
  return '不存在' if arr.empty? || num < arr.first || num > arr.last

  left, right = 0, arr.size - 1
  while left <= right
    mid = (left + right) / 2
    if arr[mid] >= num
      right = mid - 1
    else
      left = mid + 1
    end
  end

  return mid
end



p search([1,3,5,7], 1)
