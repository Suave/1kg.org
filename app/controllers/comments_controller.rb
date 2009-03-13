class CommentsController < ApplicationController
  before_filter :login_required
  
  def new
    if params[:type] == "activity"
      @comment = ActivityComment.new
    end
  end
  
  def create
    if params[:type] == "activity"
      @comment = ActivityComment.new(params[:comment])
      @comment.user = current_user
      if @comment.save
        redirect_to activity_url(@comment.activity)
      else
        if @comment.errors[:body]
          flash[:notice] = @comment.errors[:body]
        else
          flash[:notice] = "留言发布失败, 请重新登录, 再试试"
        end
        redirect_to activity_url(@comment.activity)
      end
      
    elsif params[:type] == "share"
      @comment = ShareComment.new(params[:comment])
      @comment.user = current_user
      # TODO need refactor, see application_controller
      if @comment.save
        redirect_to share_url(@comment.share)
      else
        #logger.info @comment.errors.inspect
        if @comment.errors[:body]
          flash[:notice] = @comment.errors[:body]
        else
          flash[:notice] = "留言发布失败, 请重新登录, 再试试"
        end
        redirect_to share_url(@comment.share)
      end
    end
  end
  
  def edit
    @comment = Comment.find(params[:id])
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes!(params[:comment])
    flash[:notice] = "留言修改成功"
    if @comment.type == "ActivityComment"
      redirect_to activity_url(@comment.type_id)
    elsif @comment.type == "ShareComment"
      redirect_to share_url(@comment.type_id)
    end
  end
  
  
end