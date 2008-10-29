class Admin::BoardsController < Admin::BaseController
  def new
    if params[:type] == "city"
      #setup city board, each geo item ONLY has one city board, or has NO city board
      if params[:geo].blank?
        flash[:notice] = "错误"
        redirect_to admin_geos_url
      end
      
      @geo = Geo.find(params[:geo])
      @city_board = CityBoard.new
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
    end
  end
  
  # TODO: create city board for each child geo
  def initial_generate
  end
end