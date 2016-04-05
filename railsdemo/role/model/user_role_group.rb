# == Schema Information
#
# Table name: user_role_groups
#
#  id            :integer          not null, primary key
#  role_group_id :integer
#  user_id       :integer
#  user_type     :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class UserRoleGroup < ActiveRecord::Base
  belongs_to :role_group
  belongs_to :user, polymorphic: true
end
