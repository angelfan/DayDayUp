# config/initializers/i18n_backend.rb
require 'redis-namespace'
require 'i18n/backend/active_record'
redis = Redis.new(url: Settings.Redis.url)

# 直接往redis存会不起作用 因为cache了
## 可以通过下面的代码来刷新cache
## I18n.available_locales.each do |locale|
##   I18n.backend.backends.first.ensure_freshness! locale
## end

I18n.backend = I18n::Backend::Chain.new(
    I18n::Backend::CachedKeyValueStore.new(
        Redis::Namespace.new(:i18n, redis: redis)
    ),
    I18n.backend
)

# service/*
require 'redis-namespace'

class Translator
  class InvalidTranslationError < ApplicationError
    def message
      "Redis key and value must be provided!"
    end
  end

  def self.[](key)
    @translators ||= {}
    @translators[key] ||= Translator.new(key)
  end

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
    "#{I18n.locale}-#{key}"
  end

  attr_accessor :value, :key, :locale, :redis_key

  def initialize(key)
    @key = key
  end

  def set_redis_key
    self.locale = locale.present? ? locale : I18n.locale
    @redis_key = "#{locale}.#{@key}"
  end

  def redis_value
    @redis_value = value.to_json if value
  end

  def save_by_backend!
    I18n.backend.store_translations(locale, { key => value }, escape: false)
    self.class.touch
  end

  def save_by_redis!
    if redis_key.present? && redis_value.present?
      redis.set redis_key, redis_value
    else
      raise InvalidTranslationError
    end
  end
end


# others/*
def save_from_yml_to_redis(path = "config/locales")
  Dir.chdir(path) do
    Dir.glob(File.join("**", "*.yml")).each do |file|
      yml_data = YAML.load_file(file)
      yml_data.each do |key, value|
        # 這幾種格式的i18n在yml裡是存成hash或陣列的，目前我們redis還無法支援這種格式，所以就先不存進db改load yml！
        next if %w(date datetime number time).include? key.split('.')[1]
        next if value.nil?
        translator = Translator.new(key)
        translator.value = value
        translator.redis_key = key
        translator.save_by_redis!
      end
    end
  end
end


# I18n.backend.store_translations('zh-CN', { 'page.text.free_shipping' => 'value' }, escape: false)
#
def store_translations(key, value)
  redis = Redis::Namespace.new(:i18n, redis: $redis)
  keys = ['page.cart.text1', 'page.cart_check_out.text1', 'page.text.free_shipping']

  keys.each do |key|
    {'en' => 'Worldwide Shipping',
     'ja' =>  '海外直送',
     'zh-CN' => '全球直送111',
     'zh-TW' => '全球直送'
    }.each do |locale, value|
      redis_key = "#{locale}.#{key}"
      next if redis.get(redis_key).nil?
      p [key, value]
      redis.set(redis_key, value.inspect)
    end
  end
end

