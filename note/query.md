# 总结一下常见的各种 n + 1 queries 问题

## 没有使用includes
```ruby
class Topic < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :topic
end
```

```ruby
Topic.all.each do |topic|
  topic.comments.each do |comment|
    # balabalabalabala
  end
end
```

### 解决办法
```ruby
Topic.includes(:comments).all.each do |topic|
  topic.comments.each do |comment|
    # balabalabalabala
  end
end
```

## scope查询 会造成N+1查询
```ruby
class Comment < ActiveRecord::Base
  scope :polular, -> { where("likes_count > ?": '10') }
end
```

```ruby
Topic.includes(:comments).all.each do |topic|
  topic.comments.polular.each do |comment|
    # balabalabalabala
  end
end
```

### 解决办法
```ruby
class Topic < ActiveRecord::Base
  has_many :comments
  has_many :polular_comments , -> { polular }, class_name: 'Comment'
end

class Comment < ActiveRecord::Base
  belongs_to :topic
  scope :polular, -> { where("likes_count > ?": '10') }
end
```

```ruby
Topic.includes(:comments).all.each do |topic|
  topic.polular_comments.each do |comment|
    # balabalabalabala
  end
end
```

## 遍历时 count

```ruby
Topic.includes(:comments).all.each do |topic|
  topic.comments.count
end
```

### 解决办法1
在Topic表中增加comment_count字段 增加或者删除Comment时候 trigger comment_count的数量
gem [counter_culture](https://github.com/magnusvk/counter_culture)
gem [counter_cache_with_conditions](https://github.com/skojin/counter_cache_with_conditions)

### 解决办法2
gem [eager_group](https://github.com/xinminlabs/eager_group)
