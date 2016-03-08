# serialize :json_column, JsonColumn
class JsonColumn
  attr_reader :title, :name

  def initialize(hash)
    @title = hash['title']
    @name = hash['name']
  end

  def hello
    "hello #{name}"
  end

  def dump(obj)
    MultiJson.dump(obj)
  end

  def load(json)
    return @default.call if json.nil?
    MultiJson.load(json)
  end

  # def self.dump(object)
  #   object.as_json
  # end
  #
  # def self.load(hash)
  #   self.new(hash.with_indifferent_access) if hash
  # end

  # def self.dump(object)
  #   Hashie::Mash.new object.as_json
  # end
  #
  # def self.load(hash)
  #   self.new(Hashie::Mash.new hash) if hash
  # end
end

# serialize :json_column_array, JsonColumnArray
class JsonColumnArray
  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    JsonColumnArray.new(hash.with_indifferent_access) if hash
  end

  module ArraySerializer
    def self.dump(object)
      object.as_json
    end

    def self.load(array_of_hash)
      array_of_hash.map { |hash| JsonColumnArray.new(hash.with_indifferent_access) } if array_of_hash
    end
  end
end


module HashieMashSerializers
  class PGJSONSerializer
    include Singleton

    def dump(mash)
      mash
    end

    def load(hash)
      Hashie::Mash.new(hash)
    end
  end

  # 產生一個可以存到 pg json 欄位的 Hashie::Mash, 以推翻 pg text 與 OpenStruct 的獨裁霸權
  #
  # 用法:
  #
  #     serialize :image_meta, Hashie::Mash.pg_json_serializer
  def pg_json_serializer
    PGJSONSerializer.instance
  end
end

Hashie::Mash.extend(HashieMashSerializers)
