class MedianFinder
  def initialize
    @nums = []
  end

  # @param {integer} word
  # @return {void}
  # Adds a num into the data structure.
  def add_num(num)
    insert(@nums, num)
  end

  def insert(arr, num)
    return arr << num if arr.size == 0
    return arr.push(num) if num >= arr[-1]
    return arr.unshift(num) if num <= arr[0]
    return arr.insert(1, num) if arr.size == 2

    n = arr.size - 1
    left = 1
    right = n
    while left < right
      mid = (right + left) / 2
      if num > arr[mid]
        left = mid + 1
      else
        right = mid
      end
    end
    arr.insert(left, num)
  end

  # @return {double}
  # Returns median of current data stream
  def find_median
    size = @nums.size
    return 0 if size == 0
    index = size / 2
    if size.even?
      @nums[index - 1..index].reduce(&:+).to_f / 2
    else
      @nums[index]
    end
  end
end

# Your MedianFinder object will be instantiated and called as such:
# mf = MedianFinder.new
# mf.add_num(1)
# mf.find_median()
