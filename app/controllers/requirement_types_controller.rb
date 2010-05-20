class RequirementTypesController < ApplicationController
  before_filter :login_required, :except => [:index,:show]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @validated_projects = RequirementType.non_exchangable.validated.find :all, :order => "created_at desc"
    #@pending_projects = RequirementType.non_exchangable.not_validated.find :all, :order => "created_at desc"
  end
  
  def new
    @project = RequirementType.new(:feedback_require => "")
  end
  
  
  def update
    @project = RequirementType.find params[:id]
    @project.update_attributes!(params[:project].merge({:last_modified_at => Time.now}))
  end
  
  def create
    @project = RequirementType.new(params[:project])
    @project.slug = ''
    @project.save!
    flash[:notice] = "项目已经发布，请等待管理员的审核，发布后会通过邮件通知您"
    redirect_to requirement_types_url
  end
  
  def show
    @project = RequirementType.find params[:id]
    
    @comments = @project.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
    @comment = Comment.new
    @others = RequirementType.non_exchangable.validated.find(:all, :limit => 4)
    @others.delete(@project)
  end
  
  def apply
    
  end
  
  
end