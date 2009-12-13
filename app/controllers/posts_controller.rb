class PostsController < ApplicationController
  before_filter :login_required
  before_filter :find_topic
  before_filter :post_block_check, :only => [:new, :create]
  
  def new
    @post  = Post.new
  end
  
  
  def create
    @post  = @topic.posts.build(params[:post])
    @post.user  = current_user
    @post.save!
    flash[:notice] = "回帖成功"
    redirect_to board_topic_url(@topic.board_id, @topic.id)
  end
  
  def edit
    @post  = @topic.posts.find(params[:id])
  end
  
  def update
    @post = @topic.posts.find(params[:id])
    @post.update_attributes!(params[:post])
    flash[:notice] = "回帖编辑成功"
    redirect_to board_topic_url(@topic.board_id, @topic)
  end
  
  def destroy
    @post = @topic.posts.find(params[:id])
    @topic.posts.delete(@post)
    flash[:notice] = "回帖删除成功"
    redirect_to board_topic_url(@topic.board_id, @topic)
  end
  
  private 
  def find_topic
    @topic = Topic.find(params[:topic_id])
  end
  
  def post_block_check
    if @topic.block?
      flash[:notice] = "本帖回复已关闭"
      redirect_to board_topic_url(@topic.board_id, @topic)
    end
  end
  
end