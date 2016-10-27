require 'mini_magick'
canvas = MiniMagick::Image.open('tst.jpg')

def process_crop_print_image(canvas)

  mask = MiniMagick::Image.open('Mugwort.png')

  # 建立空白背景
  background = create_blank_image(mask.width, mask.height, color: 'none')

  # 設定格式
  background.format 'png'

  # 設定品質
  background.quality '100'

  # 設定 DPI
  background.combine_options do |c|
    c.units 'PixelsPerInch'
    c.density '300'
  end

  # 大合成
  background.composite(canvas, '.png', mask) do |c|
    c.gravity 'Center'
  end
end


def create_blank_image(width, height, color: 'white', format: 'PNG32')
  tempfile = Tempfile.new(['canvas', '.png'])
  system "convert -size #{width}x#{height} xc:#{color} #{format}:#{tempfile.path}"
  MiniMagick::Image.open(tempfile.path)
ensure
  tempfile.close
  tempfile.unlink
end
#
# canvas = process_crop_print_image(canvas)
#
# canvas.write('tempfile11.png')
#
#
# mask = MiniMagick::Image.open('Mugwort.png')
# p mask.height


second_image = MiniMagick::Image.open "tst.jpg"
first_image = MiniMagick::Image.open "beerpackage_500ml_fullsize_cover.png"
result = first_image.composite(second_image) do |c|
  c.geometry 'Center'
end
result.write "output.jpg"