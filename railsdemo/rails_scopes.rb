# scope 会造成N+1查询
# 作为一个Rails开发者，我们经常使用scope来做查询，以简化你的代码，如：
class Review < ActiveRecord::Base
  belongs_to :restaurant

  scope :positive, -> { where('rating > 3.0') }
end

restauraunts = Restaurant.first(5)
restauraunts.map do |restaurant| # 该迭代会造成n+1问题
  "#{restaurant.name}: #{restaurant.reviews.positive.length} positive reviews."
end

### 解决问题 ###
# 用associations代替scopes

class Restaurant < ActiveRecord::Base
  has_many :reviews
end

class Restaurant < ActiveRecord::Base
  has_many :reviews
  has_many :positive_reviews, -> { where('rating > 3.0') }, class_name: 'Review'
end

restauraunts = Restaurant.includes(:positive_reviews).first(5)
restauraunts.map do |restaurant| # 该迭代没有n+1问题
  "#{restaurant.name}: #{restaurant.positive_reviews.length} positive reviews."
end

# 消除重复
class Review < ActiveRecord::Base
  belongs_to :restaurant

  scope :positive, -> { where('rating > 3.0') }
end

class Restaurant < ActiveRecord::Base
  has_many :reviews
  has_many :positive_reviews, -> { positive }, class_name: 'Review'
end
