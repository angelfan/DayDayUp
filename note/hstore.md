# update_all
```ruby
# Overwrite all values in the hstore
MyModel.update_all("hstore_column = hstore('key', 'value')")

# Merge in new attributes:
MyModel.update_all("hstore_column = hstore_column || hstore('key', 'value')")
```

# ransack 支援json字段检索

## 支援json字段
```ruby
ransacker :json_key do |parent|
    Arel.sql "(#{parent.table.name}.json_column->>'json_key')"
end
```

## 支援hstore
```ruby
ransacker :hstore_key do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:hstore_column], 'hstore_key')
end
```

## 使用 [hstore](http://www.postgresql.org/docs/9.4/static/hstore.html)

### 开启 hstore

```command
# execute on command
CREATE EXTENSION IF NOT EXISTS hstore;
```

### 增加hstore字段
```ruby
class AddExtraInfoTnUsers < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    add_column :users, :extra_info, :hstore
    add_index :users, :extra_info, using: :gin
  end
end
```

### 增加ExtraInfo
```ruby
class ExtraInfo
  include Virtus.model

  attribute :name,     String
  attribute :age,      Integer
  attribute :locked,   Boolean

  def self.dump(extra_info)
    extra_info.as_json
  end

  def self.load(hash)
    new(hash)
  end
end
```

### 在User中使用
```ruby
class User < ActiveRecord::Base
  serialize :extra_info, ExtraInfo
end
```

### 可以使用委托
```ruby
# Delegates `attr` and `attr=` to the delegated object.
#
# Usage:
#
#     serialize :extra_info, ExtraInfo
#     # Generates:
#     # delegate :width, :width=, :height, :height=, to: :extra_info
#     delegate_accessors :width, :height, to: :extra_info
module DelegateAccessors
  extend ActiveSupport::Concern

  module ClassMethods
    def delegate_accessors(*attrs, options)
      attrs_accessors = attrs.each_with_object([]) do |attr, array|
        array << attr << :"#{attr}="
      end

      delegate(*attrs_accessors, options)
    end
  end
end

class User < ActiveRecord::Base
  serialize :extra_info, ExtraInfo
  delegate_accessors :name, :age, :locked, to: :extra_info
end
```

### 查询

```ruby
User.where("extra_info ? :key", key: "name")

User.where("not extra_info ? :key", key: "name")

User.where("extra_info @> hstore(:key, :value)", key: "name", value: "angelfan")

User.where("extra_info -> :key LIKE :value", key: "name", value: "%fan%")

User.where("extra_info -> 'locked' = :value", value: 'true')
```

### index
```sql
CREATE INDEX extra_info_locked_key_on_users_index ON users ((extra_info -> 'locked'));
```


## 其他写法
```ruby
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
```

```ruby
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
```

```ruby
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

  # 產生一個可以存到 pg json 欄位的 Hashie::Mash,
  #
  # 用法:
  #
  #     serialize :image_meta, Hashie::Mash.pg_json_serializer
  def pg_json_serializer
    PGJSONSerializer.instance
  end
end

Hashie::Mash.extend(HashieMashSerializers)
```

