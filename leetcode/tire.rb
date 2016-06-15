class TrieNode
  attr_accessor :children, :freq, :word, :char

  def initialize(char = '', word = '')
    @children = {}
    @freq = 0
    @char = char
    @word = word
  end

  def add_child(char)
    node = self.class.new(char)
    children[char.to_sym] = node
    node.touch
    node
  end

  def touch
    self.freq += 1
  end

  def child(char)
    children.fetch(char.to_sym)
  end

  def child?(char)
    children.key?(char.to_sym)
  end
end

class Trie
  attr_reader :root

  def initialize
    @root = TrieNode.new
  end

  def insert(word)
    node = root
    word.each_char do |char|
      if node.child?(char)
        node = node.child(char)
        node.touch
      else
        node = node.add_child(char)
      end
    end
    node.word = word
  end

  def search(word)
    node = root
    word.each_char do |char|
      break unless node.child?(char)
      node = node.child(char)
    end
    (node.word == word) ? true : false
  end

  def starts_with(prefix)
    node = root
    prefix.each_char do |char|
      return false unless node.child?(char)
      node = node.child(char)
    end
    true
  end

  def starts_with_freq(prefix)
    node = root
    prefix.each_char do |char|
      if node.child?(char)
        node = node.child(char)
      else
        return 0
      end
    end
    node.freq
  end
end

trie = Trie.new
trie.insert('ruby')
trie.insert('rule')
trie.insert('java')
trie.insert('python')

p trie.search('ruby')
p trie.search('ru')
p trie.starts_with('jav')
p trie.starts_with('j2')
p trie.starts_with_freq('ru')
