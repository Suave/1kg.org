class Admin::RequirementTypesController < Admin::BaseController
  def index
    @types = RequirementType.find :all, :include => :requirements 
  end
  
  def new
    @type = RequirementType.new
  end
  
  def create
    @type = RequirementType.new(params[:type])
    @type.save!
    flash[:notice] = "产品创建成功"
    redirect_to admin_requirement_types_url
  end
  
  def edit
    @type = RequirementType.find(params[:id])
  end
  
  def update
    @type = RequirementType.find(params[:id])
    @type.update_attributes!(params[:type])
    flash[:notice] = "产品更新成功!"
    redirect_to admin_requirement_types_url
  end
  
  def destroy
    @type = RequirementType.find(params[:id])
    @type.destroy
    flash[:notice] = "删除产品 #{@type.title}"
    redirect_to admin_requirement_types_url
  end
end