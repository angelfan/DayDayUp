
def fill_str(str, i = 4)
  return str if str.size % i == 0
  str << ' ' * (4 - str.size % i)
end

def txt_cmp(f0, f1)
  str_f0 = fill_str(File.new(f0).read)
  str_f1 = fill_str(File.new(f1).read)
  a0 = str_f0.scan(/.{4}/m)
  a1 = str_f1.scan(/.{4}/m)
  n = a0.size
  m = a1.size
  s = 0
  a0.each do |txt|
    if a1.include?(txt)
      size = a1.size
      s += size - a1.keep_if { |item| item != txt }.size
    end
    break if a1.size == 0
  end
  s / [n, m].max.to_f
rescue => e
  puts "error : #{e.message}\n" << e.backtrace[0..2].join("\n")
end

(puts 'you must cmp 2 txt file'; exit) if ARGV.size != 2
r = txt_cmp(f0 = ARGV[0], f1 = ARGV[1])
puts "#{f0} and #{f1} semblance is #{r * 100}%"
