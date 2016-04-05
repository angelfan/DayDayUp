# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  action     :string(255)
#  resource   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Permission < ActiveRecord::Base
  belongs_to :role
end

# resource 和 action

# 通过这种方式去判断用户是否具该权限
# permission = {
#     action: action,
#     resource: record.is_a?(Class) ? record.name : record.class.name
# }
# user.permissions.exists?(permission)