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
  strs.inject(Hash.new([])) do |h, s|
    h[s.chars.sort.join] += [s]
    h
  end.map{|k, v| v.sort}
end