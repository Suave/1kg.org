class SharesController < ApplicationController
  before_filter :login_required, :except => [:show]
  before_filter :find_share, :except => [:create]
  
  def new
  end
  
  def create
    @share = Share.new(params[:share])
    @share.user = current_user
    @share.save!
    redirect_to share_url(@share)
  end
  
  def edit
  end
  
  def update
    @share.update_attributes!(params[:share])
    flash[:notice] = "您刚刚的修改已保存"
    redirect_to share_url(@share)
  end
  
  def destroy
    @share.destroy
    flash[:notice] = "您刚删除了活动分享<#{@share.title}>"
    redirect_to user_url(current_user)
  end
  
  
  def show
    @share.hits += 1
    @share.save!
    
    @comments = @share.comments
    @comment = ShareComment.new
  end
  
  private
  def find_share
    @share = params[:id] ? Share.find(params[:id]) : Share.new
  end
  
  
  
end