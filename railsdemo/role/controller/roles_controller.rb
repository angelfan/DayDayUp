class Print::RolesController < PrintController
  def create
    @role = Role.new(name: 'xxx')

    if @role.update(role_params)
      # something
    else
      # something
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update(role_params)
      # something
    else
      # something
    end
  end

  private

  def role_params
    role_params = params.require(:role).permit(:name, permissions: [])
    role_params[:permissions] = build_permissions(role_params[:permissions] || [])
    role_params
  end

  def build_permissions(permissions)
    parse_permissions(permissions).collect do |permission|
      @role.permissions.find_or_initialize_by(permission)
    end
  end

  def parse_permissions(permissions)
    permissions.collect do |permission|
      resource, action = permission.split('#', 2)
      { action: action, resource: resource }
    end
  end
end
