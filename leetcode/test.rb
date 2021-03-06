nums = [3, 4, 9, 14, 15, 19, 28, 37, 47, 50, 54, 56, 59, 61, 70, 73, 78, 81, 92, 95, 97, 99]

def num_subset(arr)
  # max = arr.max
  arr.sort!
  answer = 0
  # rejection = []

  (arr.size - 2).times do |time|
    arr.each_with_index do |v, i|
      target_arr = arr[i + 1..-2]
      target_arr.combination(time + 1).to_a.each do |combination|
        # rejection << combination.unshift(v) && next if rejection.include?(combination)
        sum = v + combination.reduce(&:+)

        # rejection << combination.unshift(v) && next if sum > max
        answer += 1 if arr.include?(sum)
        # rejection << combination.unshift(v) if sum == max
      end
    end
  end
  answer
end

def mem_num_subset(nums)
  nums.sort!
  max = nums.max
  mem_reach = Hash.new(0)

  nums.each do |num|
    mem_reach.dup.each do |k, v|
      next if k + num > max
      mem_reach[k + num] = mem_reach[k + num] + v
    end
    mem_reach[num] = mem_reach[num] + 1
  end
  nums.map { |n| mem_reach[n] - 1 }.reduce(&:+)
end

# p num_subset nums
p mem_num_subset nums

slices = %w(a b c d e)

def three_columns(arr)
  # return if arr.empty?
  slices = arr.sort.each_slice((arr.size / 3.0).ceil).to_a
  transform_arr = Array.new(3) { [] }
  slices.first.each_with_index do |_v, i|
    slices.each do |slice|
      # p transform_arr
      slice[i] && transform_arr[i] << slice[i]
    end
  end

  transform_arr.each { |arr| puts arr.join(' ') }
end

# three_columns slices

def new_three_columns(arr, columns)
  rows = (arr.size / columns.to_f).ceil
  puts_arr = Array.new(rows) { [] }

  (0..rows - 1).to_a.each do |row|
    (0..columns - 1).to_a.each do |column|
      puts_arr[row] << arr[rows * column + row]
    end
  end

  puts_arr.each { |arr| puts arr.join(' ') }
end

# new_three_columns([1, 2, 3, 4, 5, 6, 7, 8], 3)


#
# [1] => 1
# [1,2] => 1 2 12
# [1,2,3] => 1 2 12 13 23 123 3
#
#
# [1,2,3,4] =
# n=1 = 1
# n=2 = 1 * 2 + 1
# n=3 = (1 * 2 + 1) * 2 + 1
#
# [1,2, 3]
# 1 2 3
# 1 2 13 23
# 123

def new_combination(arr)
  combination = []
  arr.each do |i|
    combination.dup.each do |v|
      combination << v.dup.push(i)
    end
    combination << Array.new([i])
  end
  combination
end

def subsets_with_dup(nums)
  subsets = []
  last_added = [[],[]]
  nums.sort!.each_with_index do |n, i|
    last_added.shift
    temp_added = []

    if n == nums[i-1] && i != 0
      last_added[0].dup.each do |v|
        temp_added << v.dup.push(n)
        subsets << v.dup.push(n)
      end
      last_added << temp_added
    else

      subsets.dup.each do |v|
        temp_added << v.dup.push(n)
        subsets << v.dup.push(n)
      end

      temp_added << Array.new([n])
      subsets << Array.new([n])
      last_added << temp_added
      # p last_added
    end
  end
  subsets
end

p new_combination([1,2,3])


def combination_with_sum(arr)
  combination = Hash.new
  arr.each do |i|
    combination.dup.each do |k, v|
      combination[k.dup.push(i)] = v+i
    end
    combination[Array.new([i])] = i
  end
  combination
end

p combination_with_sum([1,2,3])


