class Test
  class << self
    def attrs
      Image.limit(10).map do |image|
        {
            image_name: image.image.file.filename,
            image_encode64: Base64.encode64(image.read)
        }
      end
    end

    def generate
      attrs.each do |attr|
        image = Image.new
        File.open(attr[:image_name], 'wb') do|f|
          f.write(Base64.decode64(attr[:image_encode64]))
          image.image = f
          image.save
        end
      end
    end
  end
end



Test.generate