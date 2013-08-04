# -*- encoding : utf-8 -*-
class Admin::PermissionsController < Admin::BaseController
  before_filter :find_permission, :only => [:new, :edit, :update, :destroy]
  
  def index
    @permissions = StaticPermission.find(:all)
  end
  
  def new
  end
  
  def create
    @permission = StaticPermission.new(params[:permission])
    @permission.save!
    flash[:notice] = "权限创建成功"
    redirect_to admin_permissions_path
  end
  
  def edit
  end
  
  def update
    @permission.update_attributes!(params[:permission])
    flash[:notice] = "权限编辑成功"
    redirect_to admin_permissions_path
  end
  
  def destroy
    @permission.destroy
    flash[:notice] = "权限 #{@permission.identifier} 删除成功"
    redirect_to admin_permissions_path
  end
  
  private
  def find_permission
    @permission = params[:id] ? StaticPermission.find(params[:id]) : StaticPermission.new
  end
end
