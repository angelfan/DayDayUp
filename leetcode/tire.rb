class TrieNode
  attr_accessor :children, :freq, :word, :char, :exist

  def initialize(char = '', word = '')
    # TODO: 散列换成堆
    @children = {}
    @freq = 0
    @char = char
    @word = word
    @exist = false
  end

  def add_child(char)
    node = self.class.new(char)
    children[char.to_sym] = node
    node
  end

  def add_word(word)
    self.word = word
    self.freq += 1
    self.exist = true
  end

  def exist?
    exist
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
      node = node.child?(char) ? node.child(char) : node.add_child(char)
    end
    node.add_word(word)
  end

  def freq_max(count = 10)
    pre_order.sort { |x, y| y[1] <=> x[1] }[0..count - 1]
  end

  def pre_order(node = root)
    result = []
    result.push([node.word, node.freq]) if node.exist?
    node.children.values.each do |child|
      result.concat(pre_order(child))
    end
    result
  end

  def search(word)
    node = root
    word.each_char do |char|
      break unless node.child?(char)
      node = node.child(char)
    end
    node if node.word == word
  end

  def search_like(word)
    dfs_search(root, word, 0)
  end

  def dfs_search(node, word, start)
    return true if node.exist? && start == word.size
    return false if start >= word.size

    char = word[start]

    if char == '.'
      result = false
      node.children.values.each do |child|
        if dfs_search(child, word, start + 1)
          result = true
          break
        end
      end
      return true if result
    else
      if node.child?(char)
        return dfs_search(node.child(char), word, start + 1)
      else
        return false
      end
    end

    false
  end

  def exist?(word)
    node = root
    word.each_char do |char|
      break unless node.child?(char)
      node = node.child(char)
    end
    (node.word == word) ? true : false
  end

  def starts_with?(prefix)
    node = root
    prefix.each_char do |char|
      return false unless node.child?(char)
      node = node.child(char)
    end
    true
  end

  def freq(word)
    node = root
    word.each_char do |char|
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

words = File.read(__dir__ + '/words.txt').strip.split
words.each do |word|
  trie.insert(word)
end

p trie.freq_max
p trie.freq('ruby')
p trie.search_like('.p.r..us.y')
