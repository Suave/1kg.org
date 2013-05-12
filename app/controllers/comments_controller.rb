# -*- encoding : utf-8 -*-
class CommentsController < ApplicationController
  before_filter :login_required
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
      else
        flash[:notice] = @comment.errors[:body] || "留言发布失败, 请重新登录, 再试试"
      end
      format.html { redirect_to :back}
    end
  end
  
  def edit
    @comment = current_user.admin? ? Comment.find(params[:id]) :  current_user.comments.find(params[:id])
    @commentable = @comment.commentable
  end
  
  def update
    @comment = current_user.admin? ? Comment.find(params[:id]) :  current_user.comments.find(params[:id])
    @commentable = @comment.commentable
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = "留言修改成功"
      else
        flash[:notice] = "留言内容不能为空"
      end
      format.html {redirect_to @commentable}
    end
  end
  
  def destroy
    @comment = current_user.admin? ? Comment.find(params[:id]) :  current_user.comments.find(params[:id])
    @commentable = @comment.commentable
    @commentable.comments.delete(@comment)
    
    respond_to do |format|
      flash[:notice] = "留言已删除"
      if @comment.commentable_type == "Comment"
        format.html {redirect_to url_for(@commentable.commentable)}
      else
        format.html {redirect_to url_for(@commentable)}
      end
    end
  end
  
  private
  def set_commentable
    commentable_class = params[:commentable].constantize
    commentable_id = "#{params[:commentable].underscore}_id"
    @commentable = commentable_class.find(params[commentable_id.to_sym])
  end
end
