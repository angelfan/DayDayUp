module ActionView::Helpers::Tags
  class Base
    def sanitized_value(value)
      #value.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
      value.to_s.gsub(/\s/, "_").gsub(/[^-\p{L}]/, "").downcase
      # value.to_s.gsub(/\s/, "_").gsub(/[^-\d\p{L}]/, "").downcase
    end
  end
end

# /\p{Han}/   # 汉字
# /\p{L}/ - 'Letter'