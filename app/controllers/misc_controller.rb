class MiscController < ApplicationController
  #include RubyAes
  before_filter :login_required, :only => :my_city
  
  def index
    @page_title = "首页"
    logged_in? ? public_look : render(:action => "welcome")
  end
  
  def my_city
    if @city = current_user.geo
      # 用户已经选择过同城
      redirect_to geo_url(@city)
      
    else
      # 用户还没有选择同城
      if params[:geo].blank?
        @cities = Geo.roots
        render :action => "city_select"
        
      else
        @city = Geo.find(params[:geo])
        @cities = @city.children
        
        if @cities.blank?      
          # 设置用户的同策划那个
          current_user.geo = @city unless @city.blank?
          current_user.save!
          flash[:notice] = "您已经入住#{@city.name}"
          redirect_to geo_url(@city)
        else
          # 省
          render :action => "city_select"
        end
      end
      
    end
  end
  
  
  def public_look
    @page_title = "首页"
    @title = "欢迎来到多背一公斤"
    @recent_shares = Share.recent_shares
    @hot_groups = Group.most_members
    @recent_citizens = User.recent_citizens
    
    # 网站公告
    @bulletins = Bulletin.recent
    render :action => "index"
  end
  
  def cities
    unless params[:id].blank?
      @geo = Geo.find(params[:id])
      @cities = @geo.children
    else
      @cities = Geo.roots
    end
    
  end
  
  def show_page
    #for static page
    @page = Page.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
  end

  def custom_search
    @body_class = 'white'
  end
  
  private

end