class BoardsController < ApplicationController
  def index
    #@cities = CityBoard.find(:all)
    @cities = Board.find(:all, :conditions => "(deleted_at is NULL or deleted_at='') and talkable_type = 'CityBoard'")
    @city_topics = Topic.find(:all, :conditions => ["talkable_type='CityBoard'"],
                                    :joins => :board,
                                    :order => "topics.last_replied_at desc",
                                    :limit => 10)
    
    @publics = Board.find(:all, :conditions => "(deleted_at is NULL or deleted_at='') and talkable_type = 'PublicBoard'")
    
    #@latest_activity_topics = Topic.last_10_updated_topics(ActivityBoard)
    @latest_school_topics   = Topic.last_10_updated_topics(SchoolBoard)
  end
  
  def public_issue
    # show all public & special discussion board
    @boards = Board.find(:all, :conditions => ["talkable_type='PublicBoard' and deleted_at is NULL"])
  end
  
  
  def show
    @board = Board.find(params[:id])
                                
    if @board.talkable.class == CityBoard
      @city = @board.talkable.geo
      
      @topics = @board.latest_topics
      
      @citizens = @city.users.find(:all, :order => "created_at desc", :limit => 14)
      @all_citizens = @city.users.find(:all, :order => "created_at desc", :select => "users.id")
      
      @activities = Activity.at(@city).available
      
      @shares = Share.find(:all, :conditions => ["user_id in (?)", @all_citizens.flatten],
                                 :order => "last_replied_at desc",
                                 :limit => 10)
      

      render :action => "city"
      
    elsif @board.talkable.class == PublicBoard
      @topics = @board.topics.paginate(:page => params[:page] || 1, 
                                       :include => [:user], 
                                       :per_page => 20
                                       )
      @public_board = @board.talkable
      render :action => "public"
  
    elsif @board.talkable.class == SchoolBoard
      @topics = @board.topics.paginate( :page => params[:page] || 1,
                                       :include => [:user], 
                                       :per_page => 20
                                     )
      @school_board = @board.talkable
      @school = @school_board.school
      render :action => "school"
      
    elsif @board.talkable.class == GroupBoard
      @topics = @board.topics.paginate( :page => params[:page] || 1,
                                        :include => [:user],
                                        :per_page => 20
                                      )
      @group_board = @board.talkable
      @group = @group_board.group
      
      render :action => "group"
    end
  end
  
  
  def schools
    @board = Board.find(params[:id])
    board_type_check @board
    
    @city = @board.talkable.geo
    @schools = School.get_near_schools_at(@city).paginate(:page => params[:page] || 1, 
                                                        :order => "updated_at desc", 
                                                        :per_page => 20)
    
    render :action => "city_schools"
  end
  
  def users
    # TODO load partial users, and "more" button like twitter
    get_all_citizens
    
    render :action => "city_users"
  end
  
  def shares
    get_all_citizens
    
    @shares = Share.paginate(:page => params[:page] || 1,
                             :conditions => ["user_id in (?)", @users.flatten],
                             :order => "last_replied_at desc",
                             :per_page => 10)
    render :action => "city_shares"
  end
  
  
  private
  def board_type_check(board)
    if not board.talkable.class == CityBoard
      flash[:notice] = "您刚刚访问的URL不正确, 请仔细检查核对一下"
      return redirect_to root_url
    end
  end
  
  def get_all_citizens
    @board = Board.find(params[:id])
    board_type_check @board
    
    @city = @board.talkable.geo
    @users = @city.users
  end
  
end