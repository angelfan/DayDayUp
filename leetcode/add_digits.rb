def add_digits(num)
  r = num.to_s.chars.map(&:to_i).reduce(:+)
  r <= 9 ? r : add_digits(r)
end

p add_digits(22)