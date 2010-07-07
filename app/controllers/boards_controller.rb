class BoardsController < ApplicationController
  def show
    @board = Board.find(params[:id])
    
    @topics = @board.topics.paginate(:page => params[:page] || 1, :include => [:user], :per_page => 20)
                                     
    if @board.talkable.class == PublicBoard
      @public_board = @board.talkable
      render :action => "public"
  
    elsif @board.talkable.class == SchoolBoard
      @school_board = @board.talkable
      @school = @school_board.school
      render :action => "school"
      
    elsif @board.talkable.class == GroupBoard
      @group_board = @board.talkable
      @group = @group_board.group   
      render :action => "group"
    
    elsif @board.talkable.class == Team
      @team = @board.talkable
      render :action => "team"  
      
    end
  end
end