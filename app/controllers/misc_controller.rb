class MiscController < ApplicationController
  before_filter :login_required, :only => :my_city
  
  def index
    if logged_in?
      #redirect_to my_city_url
      @recent_schools = School.recent_upload
      @recent_school_comments = Topic.last_10_updated_topics(SchoolBoard)
      @recent_shares = Share.recent_shares
      @hot_cities = Geo.hot_cities
      @recent_citizens = User.recent_citizens
      @recent_activities = Activity.available.ongoing.find(:all, :order => "id desc", :limit => 10 )
    else
      render :action => "welcome"
    end
  end
  
  def my_city
    if @city = current_user.geo
      # 用户已经选择过同城

      @city_board = @city.city_board
      @board = @city_board.board

      redirect_to board_url(@board)
      
    else
      # 用户还没有选择同城
      if params[:geo].blank?
        @cities = Geo.roots
        render :action => "city_select"
        
      else
        @city = Geo.find(params[:geo])
        @cities = @city.children
        
        if @cities.blank?
          # 市
          if @city_board = @city.city_board
            # 同城已经创建
            @board = @city_board.board
          else
            # 同城还没有创建
            @board = Board.new
            @board.talkable = CityBoard.new(:geo_id => @city.id)
            @board.save!
          end
          
          # 设置用户的同策划那个
          current_user.geo = @city unless @city.blank?
          current_user.save!
          flash[:notice] = "您已经入住#{@city.name}"
          
          redirect_to board_url(@board)
        else
          # 省
          render :action => "city_select"
        end
      end
      
    end
  end
  
  
  def public_look
    #@cities = CityBoard.find_by_sql(" select city_boards.id, city_boards.geo_id, geos.name, boards.id as board_id, count(users.id) as users_count from city_boards, users, geos, boards where boards.talkable_id=city_boards.id and boards.talkable_type='CityBoard' and city_boards.geo_id=users.geo_id and city_boards.geo_id=geos.id group by city_boards.id order by users_count desc limit 10;")
    # select count(geo_id) as count, geo_id, name from schools join geos on geos.id=schools.geo_id group by geo_id order by count desc limit 20;
=begin
    @cities = Geo.hot_cities

    @activities = Activity.ongoing.find(:all, :conditions => ["deleted_at is ?", nil], :order => "created_at desc, start_at asc", :limit => 20)

    @public_boards = PublicBoard.find(:all, :conditions => ["boards.deleted_at is NULL"],
                                            :include => [:board], 
                                            :order => "position asc",
                                            :limit => 5)
    @shares = Share.recent_shares
    
    @users = User.recent_citizens                                                              
=end
    @recent_schools = School.recent_upload
    @recent_school_comments = Topic.last_10_updated_topics(SchoolBoard)
    @recent_shares = Share.recent_shares
    @hot_cities = Geo.hot_cities
    @recent_citizens = User.recent_citizens
    @recent_activities = Activity.available.ongoing.find(:all, :order => "id desc", :limit => 10 )
    
    render :action => "index"
  end
  
  def cities
    #@cities = CityBoard.find_by_sql(" select city_boards.id, city_boards.geo_id, geos.name, boards.id as board_id, count(users.id) as users_count from city_boards, users, geos, boards where boards.talkable_id=city_boards.id and boards.talkable_type='CityBoard' and city_boards.geo_id=users.geo_id and city_boards.geo_id=geos.id group by city_boards.id having users_count >= 0 order by users_count desc;")
    #@cities = CityBoard.find(:all, :include => [:geo])
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
  
  
  
  def migration
    geo_migration
    county_migration
  end
  
  private
  # only for data migration from legacy 1kg.org based rails 1.2.3
  def geo_migration
    provinces = Area.find(:all, :conditions => "parent_id is null or parent_id=0")
    provinces.each do |province|
      new_province = Geo.new(:name => province.title, :zipcode => province.zipcode, :old_id => province.id)
      new_province.save!

      cities = Area.find(:all, :conditions => ["parent_id = ?", province.id])
      if cities.size > 0
        cities.each do |city|
          new_city = Geo.new(:name => city.title, :zipcode => city.zipcode, :old_id => city.id)
          new_city.save!
          new_city.move_to_child_of new_province
        end
      end
    end
  end

  def county_migration
    provinces = Area.find(:all, :conditions => "parent_id is null or parent_id=0")
    provinces.each do |province|
      new_province = Geo.find(:first, :conditions => ["old_id = ?", province.id])
      next if new_province.blank?
      
      cities = Area.find(:all, :conditions => ["parent_id = ?", province.id])
      
      cities.each do |city|
        new_city = new_province.children.find(:first, :conditions => ["old_id = ?", city.id])
        if new_city.blank?
          next
        else
          counties = Area.find(:all, :conditions => ["parent_id = ?", city.id])
          counties.each do |county|
            new_county = County.new(:geo_id => new_city.id, :name => county.title, :zipcode => county.zipcode, :old_id => county.id)
            new_county.save!
          end
        end
      end
    end
    flash[:notice] = "县导入成功"
  end

end