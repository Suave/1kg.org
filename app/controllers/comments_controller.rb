class CommentsController < ApplicationController
  before_filter :login_required
  before_filter :set_commentable
  
  def create
    @comment = @commentable.comments.build(params[:comment])
    respond_to do |format|
      @comment.user = current_user
      if !@comment.save
        flash[:notice] = @comment.errors[:body] || "留言发布失败, 请重新登录, 再试试"
      end
      
      if @commentable.is_a?(Post) || @commentable.is_a?(Comment) || @commentable.is_a?(Requirement)
        format.html { redirect_to :back}
      else
        format.html {redirect_to commentable_path(@commentable)}
      end
    end
  end
  
  def edit
    @comment = @commentable.comments.find(params[:id])
  end
  
  def update
    @comment = @commentable.comments.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = "留言修改成功"
      else
        flash[:notice] = "留言内容不能为空"
      end
      
      if @comment.commentable_type == "Comment"
        format.html {redirect_to commentable_path(@commentable.commentable)}
      elsif @comment.commentable_type == "Post"
        format.html {redirect_to board_topic_url(@commentable.topic.board_id, @commentable.topic)}
      else
        format.html {redirect_to commentable_path(@commentable)}
      end
      
    end
  end
  
  def destroy
    @comment = @commentable.comments.find(params[:id])
    @commentable.comments.delete(@comment)
    
    respond_to do |format|
      flash[:notice] = "留言已删除"
      if @comment.commentable_type == "Comment"
        format.html {redirect_to commentable_path(@commentable.commentable)}
      elsif @comment.commentable_type == "Post"
        format.html {redirect_to board_topic_url(@commentable.topic.board_id, @commentable.topic)}
      else
        format.html {redirect_to commentable_path(@commentable)}
      end
      
    end
  end
  
  private
  def commentable_path(commentable)
    commentable
  end
  
  def set_commentable
    commentable_class = params[:commentable].constantize
    commentable_id = "#{params[:commentable].underscore}_id"
    @commentable = commentable_class.find(params[commentable_id.to_sym])
  end
  
end