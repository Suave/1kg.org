class RequirementsController < ApplicationController
  def new
    @school = School.find params[:school_id]
    @project = RequirementType.find params[:requirement_type_id]
    
    @apply = Requirement.new
  end
  
  def create
    @project = RequirementType.find params[:requirement_type_id]
    @apply = @project.requirements.build(params[:apply])
    logger.info "apply: #{@apply.inspect}"
    @apply.save!
    flash[:notice] = "申请已提交，等待管理员审核"
    redirect_to requirement_type_url(@project)
  end
  
  
  def show
    @requirement = Requirement.find(params[:id])
  end
end