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

  # 1. 将节点从原链表中拿掉
  # 2. 将节点插入到最新节点
  def get(key)
    return -1 unless keys.key?(key)
    insert_node(unlink_node(keys[key]))
    keys[key].value
  end

  # 1. 如果已存在 和get类似的操作 只是增加了赋值
  # 2. 如果不存在 想链表写入新的节点前驱节点
  ## 所以要判断是否已满 已满就要拿掉尾节点的
  ## 后遭一个新的节点 然后插入到头结点之后
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
    # a <-> node <-> b
    # 该节点为b
    # 将当前节点的前驱节点的后继结点变为当前节点的后继节点
    # 将当前节点后继节点的前驱节点变为当前节点的前驱节点
    # 当前节点前驱后继设空
    node.prev.next = node.next
    node.next.prev = node.prev
    node.prev = nil
    node.next = nil
    node
  end

  def insert_node(node)
    # head <-> node <-> a
    # 当前节点更新为最新节点 即前驱节点为head节点
    # 将原来的最新节点变为当前节点的后继节点
    # 将原来的最新节点的前驱节点指向当前节点
    # 头结点的后继节点变为当前节点
    node.prev = head
    node.next = head.next
    head.next.prev = node
    head.next = node
  end

  # 双向链表配合hash比较容易控制缓存大小并且容易取得最不常用的节点
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
