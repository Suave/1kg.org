class TopicsController < ApplicationController
  before_filter :login_required, :except => [:show, :index,:total]
  before_filter :find_board,     :except => [:edit,:total]
  before_filter :find_topic,     :except => [:index, :create,:total]
  
  def index
    @topics = @board.topics.paginate(:page => params[:page] || 1, :per_page => 20)
  end
  
  def total
    @topics = Topic.find(:all,:limit => 100,:order => "last_replied_at desc").paginate(:page => params[:page] || 1, :per_page => 10)
  end
  
  def new
  end
  
  def create
    @topic = Topic.new(params[:topic])
    @topic.user = current_user
    @topic.board = @board
    @topic.save!
    flash[:notice] = "发帖成功"

    if @board.talkable.class == SchoolBoard
      redirect_to school_url(@board.talkable.school_id)
    elsif @board.talkable.class == GroupBoard
      redirect_to group_url(@board.talkable.group_id)
    else
      redirect_to board_url(@board)
    end
  end
  
  def edit
  end
  
  def update
    @topic.update_attributes!(params[:topic].merge({:last_modified_at => Time.now,
                                                    :last_modified_by_id => current_user.id
                                                   }))
    flash[:notice] = "帖子修改成功"
    redirect_to board_topic_url(@board, @topic)
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "帖子删除成功"
    redirect_to board_url(@board)
  end
  
  
  def show
    respond_to do |wants|
      if @topic.deleted?
        flash[:notice] = "您查看的帖子已删除"
        wants.html {redirect_to root_url}
      else
        @posts = @topic.posts.available
        @post  = Post.new
        @others  = @topic.board.topics.find(:all,:limit => 6,:order => "last_replied_at desc")- [@topic]
        wants.html
        wants.atom
      end
    end
  end
  
  def stick
    @topic.toggle!(:sticky)
    flash[:notice] = "本帖已经置顶" if @topic.sticky?
    flash[:notice] = "本帖已经取消置顶" unless @topic.sticky?
    redirect_to board_topic_url(@board, @topic)
  end
  
  def close
    @topic.toggle!(:block)
    flash[:notice] = "本帖已经关闭回复" if @topic.block?
    flash[:notice] = "本帖可以回复" unless @topic.block?
    redirect_to board_topic_url(@board, @topic)
  end
  
  
  private
  def find_board
    @board = Board.find(params[:board_id])
  end
  
  def find_topic
    @topic = params[:id].blank? ? Topic.new : Topic.find(params[:id])
  end
  
  
end