class Admin::RolesController < Admin::BaseController
  before_filter :find_role, :only => [:new, :edit, :update, :destroy]
  
  def index
    @roles = Role.find(:all)
  end
  
  def new
  end
  
  def create
    @role = Role.new(params[:role])
    @role.save!
    flash[:notice] = "创建新角色 #{@role.identifier} 成功"
    redirect_to admin_roles_path
  end
  
  def edit
  end
  
  def update
    @role.update_attributes!(params[:role])
    Role.transaction do
      @role.static_permissions.delete_all
      @role.static_permissions << params[:role][:permissions].collect{|p| StaticPermission.find(p.to_s)}
    end
    flash[:notice] = "角色修改成功"
    redirect_to admin_roles_path
  end
  
  def destroy
    @role.destroy
    flash[:notice] = "角色 #{@role.identifier} 删除成功"
    redirect_to admin_roles_path
  end
  
  private
  def find_role
    @role = params[:id] ? Role.find(params[:id]) : Role.new
  end
end