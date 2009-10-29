class Admin::BulletinsController < Admin::BaseController
  def index
    @bulletins = Bulletin.find :all, :order => "id desc", :include => :user
  end
  
  def new
    @bulletin = Bulletin.new
  end
  
  def create
    @bulletin = Bulletin.new params[:bulletin]
    @bulletin.user = current_user
    @bulletin.save!
    flash[:notice] = "公告已发布"
    redirect_to admin_bulletins_url
  end
  
  def edit
    @bulletin = Bulletin.find params[:id]
  end
  
  def update
    @bulletin = Bulletin.find params[:id]
    @bulletin.update_attributes! params[:bulletin]
    flash[:notice] = "公告修改成功"
    redirect_to admin_bulletins_url
  end
  
  def destroy
    @bulletin = Bulletin.find params[:id]
    @bulletin.destroy
    flash[:notice] = "公告删除成功"
    redirect_to admin_bulletins_url
  end
  
  
end