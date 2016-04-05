class RoleGroupsController < ApplicationController
  def create
    @role_group = RoleGroup.new(name: 'xxx', role_ids: [1, 2, 3, 4])
    if @role_group.save
      # something
    else
      # something
    end
  end
end
