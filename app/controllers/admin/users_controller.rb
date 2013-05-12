# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::BaseController
  def index
    @page_title = "管理员&版主设置"
    if params[:type] == "admin"
      @type = "admin"
      render :action => "admin"
    
    elsif params[:type] == "school"
      @type = "school"
      render :action => "school"
      
    else
      @type = "admin"
      render :action => "admin"
    end
  end
  
  def search
    @users = User.find(:all, :conditions => ["email like ? or login like ?", "%#{params[:t]}%", "%#{params[:t]}%"])
    if params[:type] == "admin"
      @type = "admin"
      render :action => "admin"
    
    elsif params[:type] == "school"
      @type = "school"
      render :action => "school"
        
    elsif params[:type] == "public"
      @public_board = PublicBoard.find(params[:board])
      render :template => "/admin/boards/edit_public"
    end
  end
  
  def update
    @user = User.find(params[:id])
    if params[:add] == "admin"
      @user.update_attribute(:is_admin,true)
      flash[:notice] = "设置 #{@user.login} 为网站管理员"
      redirect_to admin_users_path(:type => "admin")
      
    elsif params[:remove] == "admin"
      admin_count = User.admins.size
      if admin_count > 1
        @user.update_attribute(:is_admin,false)
        flash[:notice] = "取消了 #{@user.login} 网站管理员资格"
      elsif admin_count == 1
        flash[:notice] = "只剩最后一位管理员了，不能删除"
      else
        flash[:notice] = "删除错误"
      end
      redirect_to admin_users_path(:type => "admin")
    end
  end
  
  def block
    @user = User.find(params[:id])
    @user.delete!
    @user.destroy
    
    respond_to do |format|
      format.html {redirect_to root_path}
    end
  end
end
