# == Schema Information
#
# Table name: role_role_groups
#
#  id            :integer          not null, primary key
#  role_id       :integer
#  role_group_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

# 处理权限跟组别多对多的关系
class RoleRoleGroup < ActiveRecord::Base
  belongs_to :role
  belongs_to :role_group
end
