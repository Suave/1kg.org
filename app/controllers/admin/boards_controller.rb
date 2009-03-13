class Admin::BoardsController < Admin::BaseController
  
  def index
    # public board manage page in admin console
    @public_boards = PublicBoard.find(:all, :order => "position asc")
  end
  
  def new
    if params[:type] == "city"
      #setup city board, each geo item ONLY has ONE city board, or has NO city board
      if params[:geo].blank?
        flash[:notice] = "错误"
        redirect_to admin_geos_url
      end
      
      @geo = Geo.find(params[:geo])
      @city_board = CityBoard.new
      render :action => "new_city"
      
    elsif params[:type] == "public"
      #setup pulbic discussion board, only admin can create, assign moderators
      @public_board = PublicBoard.new
      render :action => "new_public"
      
    elsif params[:type] == "school"
      # confirm to create a school discussion board by admin
      if params[:school].blank?
        flash[:notice] = "错误"
        redirect_to admin_schools_url
      end
      
      @school = School.find(params[:school])
      render :action => "new_school"
    end
  end
  
  def create
    if params[:type] == "city"
      # create a city board
      @board = Board.new
      @board.talkable = CityBoard.new(params[:city_board])
      @board.save!
      flash[:notice] = "城市讨论区创建成功"
      redirect_to admin_geos_url
      
    elsif params[:type] == 'public'
      # create a public discussion board, BY admin
      @board = Board.new
      @board.talkable = PublicBoard.new(params[:public_board])
      @board.save!
      flash[:notice] = "开放讨论区创建成功"
      redirect_to admin_boards_url
      
    elsif params[:type] == 'school'
      if @school = School.find(params[:school_id])
        @board = Board.new
        @board.talkable = SchoolBoard.new(:school_id => @school.id)
        @board.save!
        flash[:notice] = "讨论区创建成功"
        redirect_to admin_school_url(@school)
      else
        flash[:notice] = "学校 id 错误"
        redirect_to admin_schools_url
      end
    end
  end
  
  def edit
    if params[:type] == 'public'
      @public_board = Board.find(params[:id]).talkable
      render :action => "edit_public"
    end
  end
  
  def update
    if params[:type] == 'public'
      @public_board = Board.find(params[:id]).talkable
      @public_board.update_attributes!(params[:public_board])
      flash[:notice] = "修改完成"
      redirect_to admin_boards_url
    end
  end
  
  def destroy
    @board = Board.find(params[:id])
    @board.destroy
    flash[:notice] = "讨论区已经彻底删除"
    redirect_to admin_boards_url
  end
  
  def deactive
    # only service for public board
    # TODO add task for other boards
    @board = Board.find(params[:id])
    @board.update_attributes!(:deleted_at => Time.now)
    flash[:notice] = "讨论区已经隐藏"
    redirect_to admin_boards_url
  end
  
  def active
    # only service for public board
    # TODO add task for other boards
    @board = Board.find(params[:id])
    @board.update_attributes!(:deleted_at => nil)
    flash[:notice] = "讨论区已经重新激活"
    redirect_to admin_boards_url
  end
  
  
  # TODO: create city board for each child geo
  def initial_generate
    
  end
end