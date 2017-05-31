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


def find(arr, num)
  arr = Array(arr)
  left, right = 0, arr.size - 1

  while left <= right
    mid = (left + right) / 2
    if arr[mid] > num
      right = mid - 1
    elsif arr[mid] < num
      left = mid + 1
    else
      return mid
    end
  end

  nil
end

p find([1,8], 8)
