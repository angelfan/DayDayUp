# Translator

# 解决I18n在片段缓存下的小方法
```ruby
class Translator
  def self.redis
    @redis ||= Redis::Namespace.new(:i18n, redis: $redis)
  end

  def self.key
    redis.get "version"
  end

  def self.touch
    redis.incr "version"
  end

  def self.cache_key
    "#{I18n.locale}#{key}"
  end
end
```
每次变更I18n可以 ```Translator.touch```
不过这样会导致所有I18n相关的cache都过期,
如果I18n频繁的变化,只能把粒度变细, 这样cache_key的计算成本相应增加
