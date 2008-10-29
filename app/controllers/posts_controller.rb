class PostsController < ApplicationController
  before_filter :login_required
  
  def create
    @topic = Topic.find(params[:topic_id])
    @post  = Post.new(params[:post])
    @post.user  = current_user
    @post.topic = @topic
    @post.save!
    flash[:notice] = "回帖成功"
    redirect_to board_topic_url(@topic.board_id, @topic.id)
  end
  
end