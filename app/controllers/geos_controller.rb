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
    @school = School.find_by_id(params[:school_id]) # option
    @map_center = [@city.latitude, @city.longitude, 9]
    
    @schools = School.paginate(:page => params[:page] || 1, :conditions => ['geo_id = ?', @city.id],
                                  :order => "updated_at desc",
                                  :per_page => 10)
    #setup_destination_stuff(@city)
    
    if !@city.children.blank?
      @cities = @city.children
      render :action => "cities"
    else
      @citizens = @city.users.find(:all, :limit => 6)
      @all_citizens = @city.users.find(:all, :order => "created_at desc", :select => "users.id")
      
      @activities_in_the_city = Activity.available.ongoing.in_the_city(@city).find :all, :order => "sticky desc, created_at desc", :limit => 10 
      @activities_from_the_city = Activity.available.ongoing.from_the_city(@city).find :all, :order => "created_at desc", :limit => 10
      @activities_on_the_fly = Activity.available.ongoing.on_the_fly(@city).find :all, :order => "created_at desc", :limit => 10 
      @all_activities = (@activities_in_the_city + @activities_from_the_city + @activities_on_the_fly).uniq.sort { |x,y| y.created_at <=> x.created_at }[0...10]
      
      @shares = Share.find(:all, :conditions => ["user_id in (?)", @all_citizens.flatten],
                                 :order => "last_replied_at desc",
                                 :limit => 6)
                                 
      @groups = @city.groups.find :all, :limit => 9
    end
=begin    
    respond_to do |format|
      if !params[:page].blank?
        format.html {render :action => 'schools', :layout => false}
      else
        format.html
      end
    end
=end
  end
  
  def box
    @city = Geo.find(params[:id])
    
    respond_to do |format|
      if !@city.children.blank?
        @cities = @city.children
        format.html {render :partial => 'geo_box', :locals => {:geos => @cities}, :layout => false}
      else
        setup_destination_stuff(@city)
        format.html {render :partial => 'city_box', :locals => {:city => @city}, :layout => false}
      end
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
      return @cities = Geo.find(:all, :conditions => [(["(LOWER(name) LIKE ?)"] * tokens.size).join(" AND "), * tokens])
    else
      @cities = Geo.roots
    end
  end
  
  def schools
    @city = Geo.find(params[:id])
    if @city.parent.nil?
      @schools = School.get_near_schools_at(@city).paginate(:page => params[:page] || 1,
                                  :order => "updated_at desc",
                                  :per_page => 10)
    else
      @schools = School.paginate(:page => params[:page] || 1, 
                                  :conditions => ['geo_id = ?', @city.id],
                                  :order => "updated_at desc",
                                  :per_page => 10)
    end
    
    respond_to do |format|
      format.html {render :layout => false}
      format.json do
        schools_json = []
        @schools.each do |school|
          next if school.basic.blank?
          schools_json << {:i => school.id,
                           :t => school.icon_type,
                           :n => school.title,
                           :a => school.basic.latitude,
                           :o => school.basic.longitude
                          }
        end
        render :text => "var schools =#{schools_json.to_json}", :layout => false
      end
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
  
  def users
    @city = Geo.find(params[:id])
    @users = @city.users
    render :action => "users"
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