# @param {Integer} n
# @return {Integer}
require 'prime'
def count_primes(n)
  Prime.each(n - 1).count
end
