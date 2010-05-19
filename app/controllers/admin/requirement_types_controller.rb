class Admin::RequirementTypesController < Admin::BaseController
  before_filter :find_project, :except => [:index, :new, :create]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @projects = RequirementType.find :all, :include => :creator 
  end
  
  def new
    @project = RequirementType.new(:feedback_require => "1. 需要上传快递\n2. 需要上传物资签\n3. 需要上传项目照片\n4. 需要写项目执行报告")
  end
  
  def create
    @project = RequirementType.new(params[:project])
    @project.validated_at = Time.now
    @project.validated_by_id = current_user.id
    @project.save!
    flash[:notice] = "项目创建成功"
    redirect_to admin_requirement_types_url
  end
  
  def edit
  end
  
  def update
    @project.update_attributes!(params[:project])
    flash[:notice] = "项目更新成功!"
    redirect_to admin_requirement_types_url
  end
  
  def destroy
    @project.destroy
    flash[:notice] = "删除项目 #{@project.title}"
    redirect_to admin_requirement_types_url
  end
  
  def validate
    @project.update_attributes!(:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    redirect_to admin_requirement_type_requirements_url(@project)
  end

  def cancel
    @project.update_attributes!(:validated_at => nil, :validated_by_id => current_user.id)
    flash[:notice] = "已取消验证"
    redirect_to admin_requirement_type_requirements_url(@project)
  end
  
  private
  def find_project
    @project = RequirementType.find params[:id]
  end
end