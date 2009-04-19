class Admin::StuffTypesController < Admin::BaseController
  def index
    @types = StuffType.find :all
  end
  
  def new
    @type = StuffType.new
  end
  
  def create
    @type = StuffType.new(params[:type])
    @type.save!
    flash[:notice] = "产品创建成功"
    redirect_to admin_stuff_types_url
  end
  
  def edit
    @type = StuffType.find(params[:id])
  end
  
  def update
    @type = StuffType.find(params[:id])
    @type.update_attributes!(params[:type])
    flash[:notice] = "产品更新成功!"
    redirect_to admin_stuff_types_url
  end
  
  def destroy
    @type = StuffType.find(params[:id])
    @type.destroy
    flash[:notice] = "删除产品 #{@type.title}"
    redirect_to admin_stuff_types_url
  end
  
  
end