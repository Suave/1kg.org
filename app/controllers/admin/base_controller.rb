class Admin::BaseController < ApplicationController
  before_filter :admin_required
  
  private
  def admin_required
    unless current_user.admin?
      flash[:notice] = "没有管理员权限"
      redirect_to root_url
    end
  end
  
end