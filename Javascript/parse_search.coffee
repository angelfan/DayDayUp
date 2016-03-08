# 不考慮重複 key 和無 value 的情況

parseSearch = (search = location.search) ->
  object = {}

  pairs = search.substring(1)# 去除前置 ? 字元
                .split('&') # 變成一堆 oo=xx 字串
  for pair in pairs
    [key, value] = pair.split('=')
    object[key] = value

  object

parseSearch('?noel=yoona&foo=bar&yoona&foo=bar')['noel'] # => yoona