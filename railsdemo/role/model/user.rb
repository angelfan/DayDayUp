class User < ActiveRecord::Base
  has_many :user_role_groups, as: :user
  has_many :role_groups, through: :user_role_groups
  has_many :roles, through: :role_groups
  has_many :permissions, through: :roles
end
