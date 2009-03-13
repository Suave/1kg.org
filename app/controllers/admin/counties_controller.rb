class Admin::CountiesController < Admin::BaseController
  
  def new
    @geo = Geo.find(params[:geo])
    @county = County.new
  end
  
  def create
    @county = County.new(params[:county])
    @county.save!
    flash[:notice] = "创建成功"
    redirect_to edit_admin_geo_url(@county.geo_id)
  end
  
  
  def edit
    @county = County.find(params[:id])
  end
  
  def update
    @county = County.find(params[:id])
    @county.update_attributes!(params[:county])
    flash[:notice] = "修改成功"
    redirect_to edit_admin_geo_url(@county.geo.id)
  end
  
  def destroy
    @county = County.find(params[:id])
    @county.destroy
    flash[:notice] = "删除成功"
    redirect_to edit_admin_geo_url(@county.geo_id)
  end
  
  
end