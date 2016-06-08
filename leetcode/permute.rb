def permute(nums)
  nums.permutation.to_a
end

# nums = [1,2,3,4]
# p permute(nums)


def permutation(nums)
  dup_nums = nums.dup
  permutation = Hash.new { |hash, key| hash[key] = [] }
  permutation[1] = [[dup_nums.shift]]

  dup_nums.each_with_index do |n, i|
    permutation_dup = permutation[i+1].dup
    permutation_dup.each do |v|
      (v.size+1).times do |index|
        permutation[i+2] << v.dup.insert(index, n)
      end
    end
  end
  permutation
end

p permutation([1])
p permutation([1,2])
p permutation([1,2,3])


def new_permutation(nums, count = nil)
  permutation = Hash.new { |hash, key| hash[key] = [] }
  permutation[1] = nums.map {|n| Array.new([n]) }
  return permutation[1] if count == 1
  (2..nums.size).to_a.each do |s|
    nums.each do |n|
      permutation[s-1].select{|p| !p.include?(n)}.map do |p|
        permutation[s] << p.dup.push(n)
      end
    end
    break if s == count
  end
  return permutation[count] if count
  permutation[nums.size]
end

p new_permutation([1,2,3], 1)
p new_permutation([1,2,3], 2)
p new_permutation([1,2,3], 3)