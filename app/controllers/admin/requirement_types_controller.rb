class Admin::RequirementTypesController < Admin::BaseController
  before_filter :find_project, :except => [:index, :new, :create]
  def index
    @projects = RequirementType.find :all, :include => :creator 
  end
  
  def new
    @project = RequirementType.new(:feedback_require => "")
  end
  
  def create
    feedback_require = feedback_require_process
    @project = RequirementType.new(params[:project])
    @project.feedback_require = feedback_require
    @project.validated_at = Time.now
    @project.validated_by_id = current_user.id
    @project.save!
    flash[:notice] = "项目创建成功"
    redirect_to admin_requirement_types_url
  end
  
  def edit
  end
  
  def update
    feedback_require = feedback_require_process
    @project.update_attributes!(params[:project])
    @project.feedback_require = feedback_require
    @project.save!
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
  def feedback_require_process
    feedback_require = ""
    feedback_require << (params[:project].values_at("need_list","need_list_photo","invoice_photo","project_photo",'letter_photo').compact.empty?? '' : "照片要求： #{params[:project].values_at("need_list","need_list_photo","invoice_photo","project_photo",'letter_photo').compact.join('、')}")
    feedback_require << "<br/> 项目进展记录要求： #{params[:project]['frequency']}"
    feedback_require << ( [params[:project]['post_letter'],params[:project]["report"]].compact.empty?? '' : "<br/> 其他要求： #{[params[:project]['post_letter'],params[:project]["report"]].compact.join('、')}")
    params[:project].delete_if {|a| ["need_list","need_list_photo","invoice_photo","project_photo","frequency","letter_photo","post_letter","report"].include?(a[0])}
    feedback_require
  end
  
  def find_project
    @project = RequirementType.find params[:id]
  end
end