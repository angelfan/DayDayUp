# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# 权限
# 每个权限下都会有相应的permissions
# 权限 跟 权组 是 多对多的关系
class Role < ActiveRecord::Base
  has_many :role_role_groups
  has_many :role_groups, through: :role_role_groups

  has_many :permissions
end