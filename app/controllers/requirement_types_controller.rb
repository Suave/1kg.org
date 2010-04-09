class RequirementTypesController < ApplicationController
  before_filter :login_required, :except => [:index]
  
  def index
    @validated_projects = RequirementType.non_exchangable.validated.find :all, :order => "created_at desc"
    #@pending_projects = RequirementType.non_exchangable.not_validated.find :all, :order => "created_at desc"
  end
  
  def new
    @project = RequirementType.new(:feedback_require => "1. 需要上传快递\n2. 需要上传物资签\n3. 需要上传项目照片\n4. 需要写项目执行报告")
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
    
    @others = RequirementType.non_exchangable.validated.find(:all, :limit => 5)
    @others.delete(@project)
  end
  
  def apply
    
  end
  
  
end