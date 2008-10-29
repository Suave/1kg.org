class BoardsController < ApplicationController
  def index
    @cities = CityBoard.find(:all)
  end
  
  
  def show
    @board = Board.find(params[:id])
    
    if @board.talkable.class == CityBoard
      @city = @board.talkable
      render :action => "city"
    end
  end
  
end