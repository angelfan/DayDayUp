# 比较值类型
def value_type_compare?(obj1, obj2)
  obj1.class == obj2.class
end

def comparable?(obj1, obj2)
  obj1.is_a?(Hash) && obj2.is_a?(Hash)
end

def diff(obj1, obj2, options = {})
  opts = { prefix: '' }.merge!(options)
  prefix = opts[:prefix]
  prefix += '.' if prefix != ''
  return [] if obj1.nil? && obj2.nil?

  return [['~', prefix, nil, obj2]] if obj1.nil?

  return [['~', prefix, obj1, nil]] if obj2.nil?

  result = []
  if comparable?(obj1, obj2)
    deleted_keys = obj1.keys - obj2.keys
    added_keys = obj2.keys - obj1.keys
    common_keys = obj1.keys & obj2.keys

    deleted_keys.each do |k|
      result << ['-', "#{prefix}#{k}", obj1[k], nil]
    end

    added_keys.sort.each do |k|
      result << ['+', "#{prefix}#{k}", nil, obj2[k]]
    end

    common_keys.each do |k|
      compare_result = diff(obj1[k], obj2[k], opts.merge(prefix: "#{prefix}#{k}"))
      result.concat compare_result unless compare_result.empty?
    end
  else
    return [] if value_type_compare?(obj1, obj2)
    return [['~', opts[:prefix], obj1, obj2]]
  end
  result
end

# obj1 = {a: 1, b: 2, d: {a: 2, b: 3}, e: {e: 1}}
# obj2 = {a: 1, c: 3, d: {a: 2, b: '2'}, f: {f: 1}}
obj1 = {
    "ticker": {
        "buy": "2876.92",
        "sell": "2883.80",
        "last": "2875.66",
        "vol": "4133.63800000",
        "vwap": 2879.12,
        "prev_close": {'a': 's'},
        "open": 2880.01
    }
}
obj2 = {
    "ticker": {
        "last": "2875.66",
        "vol": "4133.63800000",
        "date": 1396412995,
        "vwap": 2879.12,
        "prev_close": {'b': []},
        "open": '2880.02'
    }
}
p diff(obj1, obj2)
p diff({}, [])
