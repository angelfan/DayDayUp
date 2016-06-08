def permute(nums)
  nums.permutation.to_a
end

# nums = [1,2,3,4]
# p permute(nums)


def permutation(nums, flag = false)
  dup_nums = nums.dup
  permutation = [Array.new([dup_nums.shift])]
  dup_nums.each do |n|
    permutation.dup.each do |v|
      (v.size+1).times do |index|
        permutation << v.dup.insert(index, n)
      end
    end
  end
  if flag
    permutation.select!{|arr| arr.size == nums.size}
  end
  permutation
end

p permutation([1])
p permutation([1,2])
p permutation([1,2,3], true)
# [1] = 1
# [1, 2] = [1,2,] [2,1]
# [1,2,3] = [1,2,3]
#
#
# [1,2,3,4] 1, [2,3,4]    1234 2134 2314 2341
#
# 1
#
# 12 21
#
# 123 132 231 213 321 312
#
# 1234 1243 1324 1342 1432 1423 2134 2143 2314 2341 2413 2431
# 3124 3142 3241 3214 3412 3421 4123 4132 4213 4231 4312 4321