# tip
```ruby
class Data
  class << self
      include Enumerable
      delegate :each, :size, to: :all

      def all
        [1,2,3]
      end
  end
end

Data.first # 1
```