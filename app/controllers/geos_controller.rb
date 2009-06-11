class GeosController < ApplicationController
  def index
    @cities  = Geo.roots
    @map_center = Geo::DEFAULT_CENTER
    @schools = School.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      if !params[:page].blank?
        format.html {render :action => 'schools', :layout => false}
      else
        format.html
      end
    end
  end
  
  def all
    redirect_to geos_path
  end
  
  def show
    @city = Geo.find(params[:id])
    @map_center = [@city.latitude, @city.longitude, 7]
    setup_destination_stuff(@city)
    
    if !@city.children.blank?
      @cities = @city.children
    end
  end
  
  def box
    @city = Geo.find(params[:id])
    
    if !@city.children.blank?
      @cities = @city.children
      render :partial => 'geo_box', :locals => {:geos => @cities}, :layout => false
    else
      setup_destination_stuff(@city)
      render :partial => 'city_box', :locals => {:city => @city}, :layout => false
    end
  end
  
  # def city
  #   @city = Geo.find_by_slug(params[:slug])
  #   
  #   @board = @city.city_board.board
  #   @topics = @board.latest_topics
  #   
  #   @citizens = @city.users.find(:all, :order => "created_at desc", :limit => 14)
  #   @all_citizens = @city.users.find(:all, :order => "created_at desc", :select => "users.id")
  #   
  #   @activities = Activity.at(@city).available
  #   
  #   @shares = Share.find(:all, :conditions => ["user_id in (?)", @all_citizens.flatten],
  #                              :order => "last_replied_at desc",
  #                              :limit => 10)
  # end
  
  
  def search
    @query = params[:city]
    if !@query.to_s.strip.empty?
      tokens = @query.split.collect {|c| "%#{c.downcase}%"}
      @cities = Geo.find(:all, :conditions => [(["(LOWER(name) LIKE ?)"] * tokens.size).join(" AND "), * tokens])
      #logger.info("CITY: #{@city.inspect}")
      
      # search result
      #@cities = @city.collect{|c| }
=begin
      @schools = School.paginate(:per_page => 20,:page => params[:page],
                  :conditions => [(["(LOWER(address) LIKE ? OR LOWER(traffic_description) LIKE ? 
                  OR LOWER(title) LIKE ?)"] * tokens.size).join(" AND ") + 
                  "AND is_hidden = '0'",
                  * tokens.collect { |token| [token] * 3 }.flatten],
                                    :order => "created_at DESC")
=end
    else
      flash[:notice] = "您没输入搜索词"
      @cities = Geo.roots
      render :action => "action"
    end
  end
  
  def schools
    @city = Geo.find(params[:id])
    @schools = School.get_near_schools_at(@city).paginate(:page => params[:page] || 1,
                                                          :order => "updated_at desc",
                                                          :per_page => 10)
    
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  # for multiple drop down select
  def geo_choice
    if !params[:root].blank?
      if params[:root].to_i == 0
        # 用户选了不限地域
        @geos = [{:name => "不限地域", :id => 0}]
      else
        @root = Geo.find(params[:root])
        if @root.children.size > 0
          @geos = @root.children.collect{|r| {:name => r.name, :id => r.id} }
        else
          @geos = [ {:name => @root.name, :id => @root.id} ]
        end
      end
    else
      @geos = Array.new
    end
    render :partial => "/geos/geo_selector", :locals => { :object => params[:object], :method => params[:method] }
  end
  
  def county_choice
    if !params[:geo].blank?
      @geo = Geo.find(params[:geo])
      if @geo.counties.size > 0
        @counties = @geo.counties
      else
        @counties = []
      end
      render :partial => "geo_selector", :locals => { :object => "school", :method => "county" }
    end
  end
  
  private 
  def setup_destination_stuff(city)
    @schools = School.get_near_schools_at(city).paginate(:page => params[:page] || 1,
                                                          :order => "updated_at desc",
                                                          :per_page => 10)
    @shares = city.shares.paginate(:page => params[:page] || 1, :order => "comments_count desc", :per_page => 10)
    @activities = Activity.available.ongoing.find(:all, :conditions => ["arrival_id=?", city.id],
                                                        :order => "start_at desc",
                                                        :select => "id, title, start_at")
  end
  
end