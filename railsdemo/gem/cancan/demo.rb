# this file in model
class Ability
  include CanCan::Ability

  # 调用can方法 生成rule实例， 调用can?方法的时候根据当前的action去匹配相应的rule
  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :create, Event if user.invitation_accepted? || user.collaborator?
    can :update, Event do |event|
      event.user_id == user.id || event.group.collaborator?(user)
    end
    can :update, Group, user_id: user.id
    can :manage, :all if user.admin?
  end
end
