class LRUCache
  attr_reader :capacity, :keys, :head, :tail

  def initialize(capacity)
    @capacity = capacity
    @keys = {}
    @head = Node.new('head', 'head')
    @tail = Node.new('tail', 'tail')
    @head.next = @tail
    @tail.prev = @head
  end

  def get(key)
    return -1 unless keys.key?(key)
    insert_node(unlink_node(keys[key]))
    keys[key].value
  end

  def set(key, value)
    if keys.key?(key)
      insert_node(unlink_node(keys[key]))
      keys[key].value = value
    else
      keys.delete(unlink_node(tail.prev).key) if keys.size >= capacity
      keys[key] = Node.new(key, value)
      insert_node(keys[key])
    end
  end

  private

  def unlink_node(node)
    node.prev.next = node.next
    node.next.prev = node.prev
    node.prev = nil
    node.next = nil
    node
  end

  def insert_node(node)
    node.prev = head
    node.next = head.next
    head.next.prev = node
    head.next = node
  end

  class Node
    attr_accessor :prev, :next, :value
    attr_reader   :key

    def initialize(key, value)
      @key = key
      @value = value
      @prev = nil
      @next = nil
    end
  end
end
