# Active Record 4.2+
class StrippedString < ActiveRecord::Type::String
  def cast_value(value)
    value.to_s.strip
  end
end

class Work < ActiveRecord::Base
  attribute :description, StrippedString.new
end

# Virtus
class StrippedString < Virtus::Attribute
  def coerce(value)
    value.to_s.strip
  end
end

class Address
  include Virtus.model
  include ActiveModel::Validations

  attribute :street, StrippedString
end

# dry-types 0.6
module Types
  include Dry::Types.module
  StrippedString = String.constructor(->(val) { String(val).strip })
end

class Post < Dry::Types::Struct
  attribute :title, Types::StrippedString
end
