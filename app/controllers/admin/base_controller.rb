# -*- encoding : utf-8 -*-
class Admin::BaseController < ApplicationController
  before_filter :admin_required
  
  private
  def admin_required
    if not logged_in?
      flash[:notice] = "您还没有登录"
      redirect_to root_url    
    elsif not current_user.admin?
      flash[:notice] = "没有管理员权限"
      redirect_to root_url
    end
  end
  
end
