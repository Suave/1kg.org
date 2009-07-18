class Admin::UsersController < Admin::BaseController
  def index
    @page_title = "管理员&版主设置"
    if params[:type] == "admin"
      @type = "admin"
      render :action => "admin"
    
    elsif params[:type] == "school"
      @type = "school"
      render :action => "school"
    
    elsif params[:type] == "city"
      @type = "city"
      @geo_roots = Geo.roots
      render :action => "city"
      
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
        
    elsif params[:type] == "city"
      @geo = Geo.find(params[:geo])
      render :template => "admin/geos/edit"
      
    elsif params[:type] == "public"
      @public_board = PublicBoard.find(params[:board])
      render :template => "/admin/boards/edit_public"
    end
  end
  
  def update
    @user = User.find(params[:id])
    if params[:add] == "admin"
      @user.roles << Role.find_by_identifier("roles.admin")
      flash[:notice] = "设置 #{@user.login} 为网站管理员"
      redirect_to admin_users_path(:type => "admin")
      
    elsif params[:add] == "schools"
      @user.roles << Role.find_by_identifier("roles.schools.moderator")
      flash[:notice] = "设置 #{@user.login} 为学校管理员"
      redirect_to admin_users_path(:type => "school")
      
    elsif params[:add] == "school"
      school = School.find params[:school] unless params[:school].blank?
      if @user && school
        @user.roles << Role.find_by_identifier("roles.school.moderator.#{school.id}")
        flash[:notice] = "已将 #{@user.login} 设置为 #{school.title} 的爱心大使"
      else
        flash[:notice] = "系统错误"
      end
      redirect_to moderator_school_url(school)
      
    elsif params[:add] == "city"
      geo = Geo.find(params[:geo]) unless params[:geo].blank?
      
      if @user && geo
        @user.roles << Role.find_by_identifier("roles.geo.moderator.#{geo.id}")
        flash[:notice] = "设置成功"
      else
        flash[:notice] = "系统错误"
      end
      redirect_to edit_admin_geo_url(geo)
      
    elsif params[:add] == "public"
      board = Board.find(params[:board])
      @user.roles << Role.find_by_identifier("roles.board.moderator.#{board.id}")
      flash[:notice] = "设置成功"
      redirect_to edit_admin_board_url(board, :type => "public")
      
    elsif params[:add] == "love_ambas"
      
    elsif params[:remove] == "public"
      board = Board.find(params[:board])
      @user.roles.delete(Role.find_by_identifier("roles.board.moderator.#{board.id}"))
      flash[:notice] = "设置成功"
      redirect_to edit_admin_board_url(board, :type => "public")
      
    elsif params[:remove] == "city"
      geo   = Geo.find(params[:geo]) unless params[:geo].blank?
      
      @user.roles.delete(Role.find_by_identifier("roles.geo.moderator.#{geo.id}"))
      flash[:notice] = "设置成功"
      redirect_to edit_admin_geo_url(geo)

    elsif params[:remove] == "schools"
      @user.roles.delete(Role.find_by_identifier("roles.schools.moderator"))
      flash[:notice] = "取消了 #{@user.login} 学校管理员权限"
      redirect_to admin_users_path(:type => "school")
      
    elsif params[:remove] == "school"
      school = School.find params[:school] unless params[:school].blank?
      @user.roles.delete(Role.find_by_identifier("roles.school.moderator.#{school.id}"))
      flash[:notice] = "已经取消 #{@user.login} 的爱心大使身份"
      redirect_to moderator_school_url school
      
    elsif params[:remove] == "admin"
      admin_count = User.admins.size
      if admin_count > 1
        @user.roles.delete(Role.find_by_identifier("roles.admin"))
        flash[:notice] = "取消了 #{@user.login} 网站管理员资格"
      elsif admin_count == 1
        flash[:notice] = "只剩最后一位管理员了，不能删除"
      else
        flash[:notice] = "删除错误"
      end
      redirect_to admin_users_path(:type => "admin")
    end
  end
end