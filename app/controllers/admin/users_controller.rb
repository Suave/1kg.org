class Admin::UsersController < Admin::BaseController
  def index
  end
  
  def search
    @users = User.find(:all, :conditions => ["email like ? or login like ?", "%#{params[:t]}%", "%#{params[:t]}%"])
    render :action => "index"
  end
  
  def update
    @user = User.find(params[:id])
    if params[:add] == "admin"
      User.transaction do 
        @user.roles.delete_all
        @user.roles << Role.find_by_identifier("roles.admin")
      end
    elsif params[:remove] == "admin"
      admin_count = User.admins.size
      if admin_count > 1
        @user.roles.delete(Role.find_by_identifier("roles.admin"))
        flash[:notice] = "修改成功"
      elsif admin_count == 1
        flash[:notice] = "只剩最后一位管理员了，不能删除"
      else
        flash[:notice] = "删除错误"
      end
    end
    redirect_to admin_users_path
  end
end