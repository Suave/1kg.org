class BoardsController < ApplicationController
  def index
    @cities = CityBoard.find(:all)
  end
  
  
  def show
    @board = Board.find(params[:id])
    @topics = @board.topics.find(:all, :include => [:user])
    if @board.talkable.class == CityBoard
      @city_board = @board.talkable
      @city = @city_board.geo
      @citizens = @city.users
      render :action => "city"
    end
  end
  
end