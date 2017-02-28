# Given an array of strings, group anagrams together.
#
# For example, given: ["eat", "tea", "tan", "ate", "nat", "bat"],
#   Return:
#
#       [
#           ["ate", "eat","tea"],
#           ["nat","tan"],
#           ["bat"]
#       ]


# @param {String[]} strs
# @return {String[][]}
def group_anagrams(strs)
  strs.each_with_object(Hash.new([])) do |str, h|
    h[str.chars.sort.join] += [str]
  end
end
p group_anagrams ["eat", "tea", "tan", "ate", "nat", "bat"]