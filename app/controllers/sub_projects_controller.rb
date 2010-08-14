class SubProjectsController < ApplicationController
  before_filter :login_required, :except => [:show]
  before_filter :manage_project_process, :only => [:validate,:refuse,:refuse_letter]
  before_filter :find_sub_project, :only => [:show,]
  before_filter :check_permission, :only => [:edit,:update,:feedback]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:edit,:feedback]
  
  def new
    @project = Project.find params[:project_id]
    if @project.apply_end?
      flash[:notice] = "此项目的申请已经截止"
      redirect_to project_url(@project)
    end
    if @project.for_envoy && !current_user.envoy?
      flash[:notice] = "此项目只有学校大使才可以申请。" + " <a href='http://www.1kg.org/misc/school-moderator-guide'>什么是学校大使？</a>"
      redirect_to project_url(@project)
    end
    @sub_project = SubProject.new
    @schools = @project.for_envoy ? current_user.envoy_schools : (current_user.envoy_schools + current_user.visited_schools).uniq
    @school = School.find(:first,:conditions => {:id =>params[:school_id]}).nil? ? nil : School.find(params[:school_id])
    flash[:notice] = '请先完整阅读反馈要求，并仔细填写此项目申请表，带<span class="require"> * </span>号标记的为必填项。'
  end
  
  def create
    @project = Project.find params[:project_id]
    @sub_project = @project.sub_projects.build(params[:sub_project])
    @schools = @project.for_envoy ? current_user.envoy_schools : (current_user.envoy_schools + current_user.visited_schools).uniq
    if @project.for_envoy && !@sub_project.school.nil? && !User.moderators_of(@sub_project.school).include?(current_user)
      flash[:notice] = "你不是#{@sub_project.school.title}的学校大使,不能申请这个项目。"
      render :action => "new" 
    else
      
      if @sub_project.save
        flash[:notice] = "你的申请已提交成功，系统会自动通知项目管理员去审核你的申请"
        redirect_to project_url(@project)
      else
        render 'new'
      end
    end
  end
  
  def show
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
    @school = @sub_project.school
    respond_to do |want|
      want.html
    end
  end
  
  def update
    @school = @sub_project.school
    respond_to do |want|
      if @sub_project.update_attributes!(params[:sub_project])
        want.html {redirect_to project_sub_project_path(@sub_project.project, @sub_project)}
      else
        want.html {render 'edit'}
      end
    end
  end

  def validate
    @sub_project.update_attributes(:validated_at => Time.now, :validated_by_id => current_user.id)
    @sub_project.allow
    flash[:notice] = "该项目已通过申请"
    message = Message.new(:subject => "你为#{@sub_project.school.title}申请的公益项目已经通过了审核",
                            :content => "<p>你好，#{@sub_project.user.login}:</p><br/><p>你为#{@sub_project.school.title}申请的公益项目“#{@sub_project.project.title}”已经通过了项目管里员的审核。</p>\
                                         <br/><p>之后该项目的管理者会联系你，确认如何向你提供项目说明中的支持内容：</p>\
                                         <br/><p>而作为项目申请人你需要做到：</p>\
                                         <p> - 在获得支持后，按照你的执行计划按时完成项目的执行。</p>\
                                         <p> - 按照你的反馈计划，按时填写项目反馈，报告项目的进展。</p>\
                                         <br/><p>现在就去你的项目页面看看吧。 => http://www.1kg.org/projects/#{@sub_project.project.id}/sub_projects/#{@sub_project.id} </p>\
                                         <br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@sub_project.user]
    message.save!
    redirect_to manage_project_path(@sub_project.project)
  end

  def refuse
    @sub_project.refuse
    @sub_project.update_attributes(:refused_at => nil, :refused_by_id => current_user.id)
    flash[:notice] = "已拒绝申请"
    redirect_to refuse_letter_project_sub_project_url(@sub_project.project,@sub_project)
  end
  
  def refuse_letter
    flash[:notice] = "申请已拒绝，这是发给项目申请人的站内信，你可以修改此站内信的内容，说明申请被拒绝的原因。"
    @message = Message.new
    @recipient = @sub_project.user
  end
  
  def feedback
  end
  
  private
  def manage_project_process
    @sub_project = SubProject.find(params[:id])
    unless current_user = @sub_project.user || current_user.admin?
      flash[:notice] = "你没有权限进行此项操作"
      redirect_to project_path(@sub_project.project)
    end
  end

  def check_permission
    @sub_project = SubProject.find(params[:id])
    if @sub_project.user == current_user
    elsif current_user.admin?
    else
      flash[:notice] = "你没有权限进行此操作"
      redirect_to project_url(@sub_donation)
    end
  end

  
  def find_sub_project
    @sub_project = SubProject.validated.find(params[:id])
  end
end