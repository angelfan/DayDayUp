nums = [1,2,3,4,5,6,7,8,9,10, 22, 11]

def num_subset(arr)
  # max = arr.max
  answer = 0
  # rejection = []

  (arr.size-2).times do |time|
    arr.each_with_index do |v, i|
      target_arr = arr[i+1..-2]
      target_arr.combination(time+1).to_a.each do |combination|
        # rejection << combination.unshift(v) && next if rejection.include?(combination)
        sum =  v + combination.reduce(&:+)

        # rejection << combination.unshift(v) && next if sum > max
        answer += 1 if arr.include?(sum)
        # rejection << combination.unshift(v) if sum == max
      end
    end
  end
  answer
end

p num_subset nums

def mem_num_subset(nums)
  nums.sort!
  mem_reach = Hash.new(-1)
  nums.each do |num|
    mem_reach.each do |k, v|
      next if k+num > max

      mem_reach[k+num] = mem_reach[k+num] + v
    end
    mem_reach[n] = mem_reach[n] + 1
  end
end
p num_subset nums


slices = ['a', 'b', 'c', 'd', 'e']
def three_columns(arr)
  # return if arr.empty?
  slices = arr.sort.each_slice((arr.size / 3.0).ceil).to_a
  transform_arr = Array.new(3){[]}
  slices.first.each_with_index do |_v, i|
    slices.each do |slice|
      # p transform_arr
      slice[i] && transform_arr[i] << slice[i]
    end
  end

  transform_arr.each { |arr| puts arr.join(' ')}
end

# three_columns slices


def new_three_columns(arr, columns)
  rows = (arr.size / columns.to_f).ceil
  puts_arr = Array.new(rows){[]}

  (0..rows-1).to_a.each do |row|
    (0..columns-1).to_a.each do |column|
      puts_arr[row] << arr[rows * column + row]
    end
  end

  puts_arr.each { |arr| puts arr.join(' ')}
end

new_three_columns([1,2,3,4,5,6,7,8], 3)




