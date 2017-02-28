def parent(i)
 i / 2
end

def left(i)
  2 * i
end

def right(i)
  2 * i + 1
end

def max_heap_fiy(array, i)
  l = left(i)
  r = right(i)
  if l <= array.size && array[l].to_i > array[i]
    largest = l
  else
    largest = i
  end

  if r <= array.size && array[r] > array[i]
    largest = r
  end

  if largest != i
    array[i], array[largest] = array[largest], array[i]
    max_heap_fiy(array, largest)
  end
end

a = [1,2,3,6,5,4]
max_heap_fiy(a, 0)
p a