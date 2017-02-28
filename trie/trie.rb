require_relative 'word'
require_relative 'trie_node'

class Trie
  attr_reader :root

  def initialize
    @root = TrieNode.new
  end

  def insert(word, possible_chars)
    return if word.empty?
    node = root
    word.each_char do |char|
      node = node.child?(char) ? node.child(char) : node.add_child(char)
    end
    node.add_possible_chars(possible_chars)
  end

  def search(word)
    node = root
    word.each_char do |char|
      return nil unless node.child?(char)
      node = node.child(char)
    end
    node
  end
end


trie = Trie.new

trie.insert('abc', nil)
trie.insert('ab*', ['c'])
trie.insert('a*c', ['b'])
trie.insert('a**', ['b', 'c'])
trie.insert('a**', ['b', 'd'])