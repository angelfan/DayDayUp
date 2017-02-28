require 'json'
require 'redis'

REDIS = Redis.new(:url => 'redis://localhost:6379/0')

class TrieNode
  attr_accessor :key, :possible_chars

  def initialize(key = '')
    @key = key
  end

  def add_child(char)
    return if char.to_s.empty?
    child_key = key + char
    REDIS.set(child_key, {}.to_json)
    TrieNode.new(child_key)
  end

  def add_possible_chars(chars)
    Array(chars).each do |char|
      possible_chars[char] += 1
    end
    REDIS.set(key, possible_chars.to_json)
  end

  def possible_chars
    @possible_chars ||= Hash.new(0).merge(JSON.parse(REDIS.get(key) || "{}"))
  end

  def child?(char)
    return nil if char.to_s.empty?
    REDIS.get(key + char)
  end

  def child(char)
    child_key = key + char
    TrieNode.new(child_key)
  end
end
