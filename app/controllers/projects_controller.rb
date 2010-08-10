class ProjectsController < ApplicationController
  before_filter :find_project, :except => [:new, :create, :index]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]

  def index
    @validated_projects = Project.validated.find :all, :order => "created_at desc"
  end
  
  def show
      @others = []
  end
  
  def new
      @project = Project.new(:feedback_require => "")
  end

  def create
    feedback_require = feedback_require_process
    @project = Project.new(params[:project])
    @project.feedback_require = feedback_require
    @project.save!  
    flash[:notice] = "项目创建成功"
    redirect_to projects_url
  end
  
  private

  def find_project
    @project = Project.validated.find(params[:id])
  end
  
  def feedback_require_process
    feedback_require = ""
    feedback_require << (params[:project].values_at("need_list","need_list_photo","invoice_photo","project_photo",'letter_photo').compact.empty?? '' : "照片要求： #{params[:project].values_at("need_list","need_list_photo","invoice_photo","project_photo",'letter_photo').compact.join('、')}")
    feedback_require << "<br/> 项目进展记录要求： #{params[:project]['frequency']}"
    feedback_require << ( [params[:project]['post_letter'],params[:project]["report"]].compact.empty?? '' : "<br/> 其他要求： #{[params[:project]['post_letter'],params[:project]["report"]].compact.join('、')}")
    params[:project].delete_if {|a| ["need_list","need_list_photo","invoice_photo","project_photo","frequency","letter_photo","post_letter","report"].include?(a[0])}
    feedback_require
  end

end