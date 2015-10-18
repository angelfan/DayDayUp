# coding: utf-8
class Array
  # 冒泡排序
  def bubble_sort!
    sort_arr = dup
    index = 1
    while index < sort_arr.length
      (0...sort_arr.length - index).to_a.each do |i|
        sort_arr[i], sort_arr[i + 1] = sort_arr[i + 1], sort_arr[i] if sort_arr[i] > sort_arr[i + 1]
      end
      index += 1
    end
    sort_arr
  end

  # 快速排序
  def quick_sort
    return [] if self.empty?
    x, *a = self
    left, right = a.partition { |t| t < x }
    left.quick_sort + [x] + right.quick_sort
  end

  def insert_sort
    sort_arr = dup
    (0...sort_arr.length).to_a.each do |j|
      key = sort_arr[j]
      i = j - 1
      while i >= 0 && sort_arr[i] > key
        sort_arr[i + 1] = sort_arr[i]
        i -= 1
      end
      sort_arr[i + 1] = key
    end
    sort_arr
  end

  def merge_sort!
    return self if size <= 1
    left = self[0, size / 2]
    right = self[size / 2, size - size / 2]
    Array.merge(left.merge_sort, right.merge_sort)
  end

  def self.merge(left, right)
    sorted = []
    until left.empty? || right.empty?
      sorted << (left.first <= right.first ? left.shift : right.shift)
    end
    sorted + left + right
  end
end

a = [2, 3, 1, 0]
p a.insert_sort
