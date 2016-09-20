require 'benchmark'



p Benchmark.realtime { 3.times { system `cwebp -q 100 Mugwort.png -o image.webp` } }
p Benchmark.realtime { 100000.times { 1 + 1 }  }



Benchmark.bm do |x|
  x.report { 1 + 1 }
  x.report { 3.times { system `cwebp -q 100 Mugwort.png -o image.webp` }}
end


target_path = 'Mugwort.png'

file_path = 'imagexxx.webp'
out_filename = File.expand_path(File.join(File.dirname(__FILE__), "4.webp"))

p file_path
p out_filename
require 'webp_ffi'
p WebP.encode(target_path, out_filename, quality: 100)

target_path = 'Mugwort.png'
file_path = 'image2.png'
p Benchmark.realtime { system `convert -auto-orient #{target_path} #{file_path}` }
p Benchmark.realtime { system `mogrify -auto-orient #{target_path}` }


class Hash
  # Merges the caller into +other_hash+. For example,
  #
  #   options = options.reverse_merge(size: 25, velocity: 10)
  #
  # is equivalent to
  #
  #   options = { size: 25, velocity: 10 }.merge(options)
  #
  # This is particularly useful for initializing an options hash
  # with default values.
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  # Destructive +reverse_merge+.
  def reverse_merge!(other_hash)
    # right wins if there is no left
    merge!( other_hash ){|key,left,right| left }
  end
  alias_method :reverse_update, :reverse_merge!
end

require 'graphicsmagick'

img = GraphicsMagick::Image.new(target_path)
a = Benchmark.realtime do
  img.auto_orient
  img.strip
  # img.write('my_new_file.png')
  p img.write!
end
p a


sw.remote_
require 'mini_magick'

image = ::MiniMagick::Image.open(target_path)
b = Benchmark.realtime do
  image.auto_orient
  image.strip
  image.write('my_new_file2.png')
  p image.path
  image.run_command("identify", 'my_new_file2.png')
end

p b


img = GraphicsMagick::Image.new(target_path)

p img.mime_type
p image.mime_type



Benchmark.realtime { w.remote_print_image_url = url }
Benchmark.realtime { w.save }

require 'mini_magick'

tempfile = Tempfile.new(['canvas', '.png'])
system "convert -size 500*500 xc:white PNG32:#{tempfile.path}"
target_path = 'Mugwort.png'
file_path = 'ad.jpg'
canvas = MiniMagick::Image.open(target_path)

watermark = MiniMagick::Image.open(file_path)
canvas = canvas.composite(watermark) do |c|
  c.gravity 'Center'
end
canvas.write('tempfile.png')
