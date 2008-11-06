class TopicsController < ApplicationController
  before_filter :login_required, :except => [:show, :index]
  
  def new
    @board = Board.find(params[:board_id])
    if @board.talkable.class == CityBoard
      @board_name = @board.talkable.geo_name + "同城"
    end
    @topic = Topic.new
  end
  
  def create
    @board = Board.find(params[:board_id])
    @topic = Topic.new(params[:topic])
    @topic.user = current_user
    @topic.board = @board
    @topic.save!
    flash[:notice] = "发帖成功"
    redirect_to board_url(@board)
  end
  
  def show
    @board = Board.find(params[:board_id])
    @topic = Topic.find(params[:id])
    @posts = @topic.posts
    @post  = Post.new
  end
  
end