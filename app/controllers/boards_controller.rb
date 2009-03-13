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
      
      @citizens = @city.users.find(:all, :order => "created_at desc", :limit => 16)
      @all_citizens = @city.users.find(:all, :order => "created_at desc", :select => "users.id")
      
      @activities = Activity.at(@city).available
      
      @shares = Share.find(:all, :conditions => ["user_id in (?)", @all_citizens.flatten],
                                 :order => "updated_at desc")
      

      render :action => "city"
      
    elsif @board.talkable.class == PublicBoard
      @topics = @board.topics.available.paginate(:page => params[:page] || 1, 
                                                 :order => "last_replied_at desc",
                                                 :include => [:user], 
                                                 :per_page => 20
                                                 )
      @public_board = @board.talkable
      render :action => "public"
  
    elsif @board.talkable.class == SchoolBoard
      @topics = @board.topics.available.paginate(:page => params[:page] || 1,
                                                 :order => "last_replied_at desc",
                                                 :include => [:user], 
                                                 :per_page => 20
                                                 )
      @school_board = @board.talkable
      @school = @school_board.school
      render :action => "school"
    end
  end
  
  
  def schools
    @board = Board.find(params[:id])
    board_type_check @board
    
    @city = @board.talkable.geo
    @schools = School.at(@city).validated.paginate(:page => params[:page] || 1, 
                                                   :order => "updated_at desc", 
                                                   :per_page => 20)
    
    render :action => "city_schools"
  end
  
  def users
    @board = Board.find(params[:id])
    board_type_check @board
    
    @city = @board.talkable.geo
    @users = @city.users
    
    render :action => "city_users"
  end
  
  private
  def board_type_check(board)
    if not board.talkable.class == CityBoard
      flash[:notice] = "您刚刚访问的URL不正确, 请仔细检查核对一下"
      return redirect_to root_url
    end
  end
  
end