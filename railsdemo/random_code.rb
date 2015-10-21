def newpass( len )
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newpass = ""
  1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
  return newpass
end


def generate_activation_code(size = 6)
charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
(0...size).map{ charset.to_a[rand(charset.size)] }.join
end

p newpass(11)

p (0...50).map { ('a'..'z').to_a[rand(26)] }.join

p rand(36**4).to_s(33)

p (0...2).map { rand(1..9) }.join()

(0...50).map { ('a'..'z').to_a[rand(26)] }.join

def rand_name(len=9)
  ary = [('0'..'9').to_a, ('a'..'z').to_a, ('A'..'Z').to_a]
  name = ''

  len.times do
    name << ary.choice.choice
  end
  name
end


def random_code(digit)
  return if digit < 1
  code = ''
  digit.times do ||
    code += rand(1..9).to_s
  end
  code

  # digit.times { |a| a.to_s += rand(1..9).to_s }
end

p '%1d' % rand(10 ** 10)

p rand(10 ** 10).to_s.rjust(20,'1')

p rand(9999999999).to_s.center(2, rand(9).to_s)

p "hello".center(2)