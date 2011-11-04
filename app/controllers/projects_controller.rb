class ProjectsController < ApplicationController
  
  before_filter :login_required, :except => [:show,:index,:large_map,:topics,:photos] 
  before_filter :find_project, :except => [:new, :create, :index]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]

  def index
    @validated_projects = Project.validated.find :all, :order => "created_at desc"
  end
  
  def show
    @executions = @project.executions.validated
    @my_executions = @project.executions.find(:all,:conditions => {:user_id => current_user.id}) if current_user
    @comments = @project.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
    @comment = Comment.new
    @photos = @executions.map(&:photos).flatten
    @topics = @executions.map(&:topics).flatten
    @map_center = Geo::DEFAULT_CENTER
    @json = []
    @executions.compact.each do |e|
      next if e.community.basic.blank?
      @json << {:i => e.id,
                       :n => e.community.title,
                       :a => e.community.basic.latitude,
                       :o => e.community.basic.longitude
                       }
    end
    #为旱灾调研项目的hack
    if @project.id == 6
      @villages = (Village.all - @executions.map(&:village))
    end
  end
  
  def new
    @project = Project.new(:feedback_require => "")
  end
  
  def edit
  end

  def update
    feedback_require = feedback_require_process
    @project.update_attributes!(params[:project])
    @project.feedback_require = feedback_require
    @project.save
    flash[:notice] = "修改成功"
    redirect_to project_url(@project)
  end
  
  def create
    feedback_require = feedback_require_process
    @project = Project.new(params[:project])
    @project.feedback_require = feedback_require
    @project.user = current_user
    debugger
    @project.save
    flash[:notice] = "项目创建成功"
    message = Message.new(:subject => "#{@project.user.login}创建了的公益项目#{@project.title}",
                          :content => "<p>请去网站后台查看</p>"
                          )
    message.author_id = 0
    message.to = User.admins
    message.save!
    
    redirect_to projects_url
  end
  
  def manage
    @executions = @project.executions
  end
  
  def large_map
    @json = []
    @executions = @project.executions.validated
    @map_center = Geo::DEFAULT_CENTER
    @executions.compact.each do |e|
      next if e.community.blank?
      @json << {:i => e.id,
                       :n => e.community.title,
                       :a => e.community.basic.latitude,
                       :o => e.community.basic.longitude
                       }
    end
  end
  
  def topics
    @executions = @project.executions.validated
    @topics = @executions.map(&:topics).flatten.paginate(:page => params[:page], :per_page => 20)
  end
  
  def photos
    @executions = @project.executions.validated
    @photos = @executions.map(&:photos).flatten.paginate(:page => params[:page], :per_page => 20)
  end
    
  private

  def find_project
    if current_user && current_user.admin?
      @project = Project.find(params[:id])
    else
      @project = Project.validated.find(params[:id])
    end
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
