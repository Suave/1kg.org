class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :update]
  before_filter :login_required, :only => [:edit, :update, :suspend, :unsuspend, :destroy, :purge]

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      render :action => "wait_activation"
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !self.current_user.active?
      self.current_user.activate!
      flash[:notice] = "注册完成，补充一下你的个人信息吧"
      redirect_back_or_default("/setting")
    else
      flash[:notice] = "激活码不正确，请联系 feedback@1kg.org"
      redirect_back_or_default("/")
    end
    
  end
  
  def edit
    @page_title = "编辑个人信息"
    @user = current_user
    
    if params[:type] == "account"
      @type = "account"
      render :action => "setting_account"
    elsif params[:type] == "live"
      @type = "personal"
      
      @live_geo = @user.geo
      #logger.info("LIVE GEO: #{@live_geo.inspect}")
      @current_geo = (params[:live].blank? ? @live_geo : Geo.find(params[:live]))
      #logger.info("CURRENT_GEO: #{@current_geo.inspect}")
      if @current_geo
        @same_level_geos = @current_geo.siblings
        @next_level_geos = @current_geo.children
      else
        @same_level_geos = Geo.roots
        #logger.info("SAME LEVEL GEOS: #{@same_level_geos.inspect}")
        @next_level_geos = nil
      end
      
      render :action => "setting_live"
    else
      @type = "personal"
      render :action => "setting_personal"
    end
  end
  
  def update
    if params[:for] == 'login'
      @user.update_attributes!(params[:user])
      flash[:notice] = "用户名修改成功"
      redirect_to setting_url(:type => 'account')
    
    
      
    elsif params[:for] == 'password'
      @user.update_attributes!(params[:user])
      #self.current_user = @user
      flash[:notice] = "密码修改成功"
      redirect_to setting_url(:type => 'account')
    
    
      
    elsif params[:for] == 'avatar'
      # convert user's avatar to gif format, thanks for Robin Lu
      iconfile = params[:user][:avatar_url]
      unless iconfile.blank?
        # if user upload avatar, convert file format
        img = ::Magick::Image::from_blob(iconfile.read).first
        img.crop_resized!(72,72)
        filename = File.join(RAILS_ROOT + "/public/user/avatar_url/tmp", 'icon.gif')
        img.write(filename)
        iconfile = File.open(filename)
        params[:user][:avatar_url] = iconfile
      end
      @user.update_attributes!(params[:user])
      flash[:notice] = "头像修改成功"
      redirect_to setting_url(:type => "personal")
    
    
      
    elsif params[:for] == 'live'
      @geo = Geo.find(params[:geo])
      @user.geo = @geo unless @geo.blank?
      @user.save!
      flash[:notice] = "居住地修改成功"
      redirect_to setting_url(:type => "personal")
      
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
