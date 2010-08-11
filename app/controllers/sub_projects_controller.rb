class SubProjectsController < ApplicationController
  before_filter :login_required, :except => [:show] 
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:edit, :update]
  
  def new
    @project = Project.find params[:project_id]
    if @project.apply_end?
      flash[:notice] = "此项目的申请已经截止"
      redirect_to project_url(@project)
    end
    if @project.must && !current_user.envoy?
      flash[:notice] = "此项目只有学校大使才可以申请。" + " <a href='http://www.1kg.org/misc/school-moderator-guide'>什么是学校大使？</a>"
      redirect_to project_url(@project)
    end
    @apply = Requirement.new
    @schools = @project.must ? current_user.envoy_schools : (current_user.envoy_schools + current_user.visited_schools).uniq
    @school = School.find(:first,:conditions => {:id =>params[:school_id]}).nil? ? nil : School.find(params[:school_id])
    
  end
  
  def create
    @project = Project.find params[:requirement_type_id]
    @apply = @project.requirements.build(params[:apply])
    @schools = @project.for_envoy ? current_user.envoy_schools : (current_user.envoy_schools + current_user.visited_schools).uniq
    @apply.status = 2
    if @project.must && !User.moderators_of(@apply.school).include?(current_user)
      flash[:notice] = "你不是#{@apply.school.title}的学校大使,不能申请这个项目。"
      render :action => "new" 
    else
      
    @apply.save!
    flash[:notice] = "申请已提交，等待管理员审核"
    redirect_to project_url(@project)
    end
  end
  
  
  def show
    @sub_project = SubProject.find(params[:id])
    @school = @sub_project.school
    
    respond_to do |want|
        @comments = @sub_project.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
        @comment = Comment.new
        @photos = @sub_project.photos
        @shares = @sub_project.shares
        want.html
    end
  end
  
  def edit
    @requirement = Requirement.find(params[:id])
    @school = @requirement.school
    respond_to do |want|
      if (@requirement.applicator == current_user) || current_user.admin?
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
      if @requirement.update_attributes!(params[:requirement])
        want.html {redirect_to school_requirement_path(@school, @requirement)}
      else
        want.html {render 'edit'}
      end
    end
  end
end