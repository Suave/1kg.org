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
      save_comment @comment
      
    elsif params[:type] == "share"
      @comment = ShareComment.new(params[:comment])
      save_comment @comment
      
    elsif params[:type] == "guide"
      @comment = GuideComment.new params[:comment]
      save_comment @comment
      
    elsif params[:type] == "bulletin"
      @comment = BulletinComment.new params[:comment]
      save_comment @comment
    end
    
    redirect_to_correct_page @comment
  end
  
  def edit
    @comment = Comment.find(params[:id])
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes!(params[:comment])
    flash[:notice] = "留言修改成功"
    redirect_to_correct_page @comment
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    @comment.update_attributes!(:deleted_at => Time.now)
    flash[:notice] = "留言已删除"
    redirect_to_correct_page @comment
  end
  
  private
  def save_comment(comment)
    comment.user = current_user
    unless comment.save
      if comment.errors[:body]
        flash[:notice] = comment.errors[:body]
      else
        flash[:notice] = "留言发布失败, 请重新登录, 再试试"
      end
    end
  end
  
  def redirect_to_correct_page(comment)
    if comment.type == "ActivityComment"
      
      redirect_to activity_url(comment.activity)
      
    elsif comment.type == "ShareComment"
      
      redirect_to share_url(comment.share)
      
    elsif comment.type == "GuideComment"
      
      redirect_to school_guide_url(comment.school_guide.school, comment.school_guide)
    
    elsif comment.type == "BulletinComment"
      
      redirect_to bulletin_url(comment.bulletin)
      
    end
  end
  
end