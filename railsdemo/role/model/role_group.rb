# == Schema Information
#
# Table name: role_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# 权组
# 权限 跟 权组 是 多对多的关系
class RoleGroup < ActiveRecord::Base
  has_many :role_role_groups
  has_many :roles, through: :role_role_groups
end
