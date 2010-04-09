class RequirementsController < ApplicationController
  def new
    @schools = current_user.envoy_schools
    @school = School.find(:first,:conditions => {:id =>params[:school_id]}).nil? ? nil : School.find(params[:school_id])
    @project = RequirementType.find params[:requirement_type_id]
    
    @apply = Requirement.new
  end
  
  def create
    @project = RequirementType.find params[:requirement_type_id]
    @apply = @project.requirements.build(params[:apply])
    @schools = current_user.envoy_schools
    #@school = School.find params[:apply][:school_id]
    @apply.status = 2
    @apply.save!
    flash[:notice] = "申请已提交，等待管理员审核"
    redirect_to requirement_type_url(@project)
  end
  
  
  def show
    @requirement = Requirement.find(params[:id])
    @school = School.find_by_id(params[:school_id])
    
    respond_to do |want|
      if @school
        want.html { render 'school'}
      else
        want.html
      end
    end
  end
  
  def edit
    @requirement = Requirement.find(params[:id])
    @school = @requirement.school
    respond_to do |want|
      if (@requirement.applicator == current_user) && current_user.school_moderator?
        want.html
      else
        flash[:notice] = "对不起，您没有权限更新此项目的反馈报告"
        want.html { redirect_to school_requirement_path(@school, @requirement)}
      end
    end
  end
  
  def update
    @requirement = Requirement.find(params[:id])
    @school = @requirement.school
    respond_to do |want|
      if User.moderators_of(@school).include?(current_user) && 
        !current_user.school_moderator? && @requirement.update_attributes(:feedback => params[:requirement][:feedback])
        want.html { redirect_to school_requirement_path(@school, @requirement)}
      else
        flash[:notice] = "对不起，您没有权限更新此项目的反馈报告"
        want.html { redirect_to school_requirement_path(@school, @requirement)}
      end
    end
  end
end