# 核心方法
def authorize(record, query = nil)
  # 空指针保护
  # 通过action取得对应的policy中的方法，
  # query可被指定
  query ||= params[:action].to_s + '?'

  @_pundit_policy_authorized = true

  # 该部将对应的policy类实例化
  # 核心方法PolicyFinder.find, 参数record, 即object
  policy = policy(record)

  # 执行policy中对应的方法
  # 如果没有找到则报错
  unless policy.public_send(query)
    fail NotAuthorizedError.new(query: query, record: record, policy: policy)
  end

  true
end

# 主要就是通过调用一个policy获取返回值，以便决定是否可以继续下面的操作
