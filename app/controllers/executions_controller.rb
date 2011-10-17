class ExecutionsController < ApplicationController
  before_filter :login_required, :except => [:show,:info_window,:apply_box]
  before_filter :manage_project_process, :only => [:validate,:refuse,:refuse_letter]
  before_filter :check_permission, :only => [:edit,:update,:feedback,:finish]
  before_filter :find_execution, :only => [:show,:info_window]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:feedback]
  
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
    @execution = Execution.new
    @schools = @project.for_envoy ? current_user.envoy_schools : (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
    @school = School.find(:first,:conditions => {:id =>params[:school_id]}).nil? ? nil : School.find(params[:school_id])
    flash[:notice] = '请先完整阅读反馈要求，并仔细填写此项目申请表，带<span class="require"> * </span>号标记的为必填项。'
  end
  
  def create
    @project = Project.find params[:project_id]
    @execution = @project.executions.build(params[:execution])
    @schools = @project.for_envoy ? current_user.envoy_schools : (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
    if @project.for_envoy && !@execution.school.nil? && !User.moderators_of(@execution.school).include?(current_user)
      flash[:notice] = "你不是#{@execution.school.title}的学校大使,不能申请这个项目。"
      render :action => "new" 
    else
      if @execution.save
        flash[:notice] = "你的申请已提交成功，系统会自动通知项目管理员去审核你的申请"
        message = Message.new(:subject => "#{@project.title}有了新的申请",
                              :content => "<p>你好，#{@project.user.login}:</p><br/><p>#{@execution.user.login}申请了你的公益项目（“#{@project.title}”）</p>\
                                           <br/><p>去检查一下他的申请吧，作出通过或者拒绝的判断。 => http://www.1kg.org/projects/#{@project.id}/manage </p>\
                                           <br/><p>多背一公斤团队</p>"
                                )
        message.author_id = 0
        message.to = [@project.user]
        message.save!
      
        redirect_to project_url(@project)
      else
        render 'new'
      end
    end
  end
 
  def show
    if @execution.with_box?
      redirect_to "/boxes/execution/#{@execution.id}" 
    else
      @school = @execution.school
      respond_to do |want|
          @comments = @execution.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
          @comment = Comment.new
          @photos = @execution.photos
          @shares = @execution.shares
          want.html
      end
    end
  end
  
  def edit
      respond_to do |want|
        unless @execution.validated?
          want.html
        else
          flash[:notice] = "已经通过的项目不能再修改"
          want.html { redirect_to @project }
        end
        
      end
  end
  
  def update
    respond_to do |want|
      if @execution.update_attributes!(params[:execution])
        #针对不同的项目状态判断更新的内容是申请表还是反馈
        if @execution.validated?
          if params[:is_finish] #如果声明项目结束，站内信通知发起人查看
            @execution.finish
            message = Message.new(:subject => "#{@school.title}的项目已经完成",
                                  :content => "<p>你好，#{@project.user.login}:</p><br/>\
                                               <p>#{@execution.user.login}在#{@school.title}的公益项目已经完成了。（“#{@project.title}”）</p>\
                                               <br/><p>去看看他的反馈报告吧。 => http://www.1kg.org/projects/#{@project.id}/executions/#{@execution.id} </p>\
                                               <br/><p>多背一公斤团队</p>"
                                    )
            message.author_id = 0
            message.to = [@project.user]
            message.save!
            flash[:notice] = "已经声明项目完成,通知了项目发起人"
            want.html  {redirect_to project_execution_path(@project, @execution)}
          else  
            flash[:notice] = "反馈更新成功"
            want.html {redirect_to project_execution_path(@project, @execution)}
          end
        else
          flash[:notice] = "申请表修改成功"
      
          message = Message.new(:subject => "#{@project.title}的申请有了更新",
                                  :content => "<p>你好，#{@project.user.login}:</p><br/><p>#{@execution.user.login}更新了他的公益项目申请（“#{@project.title}”）</p>\
                                               <br/><p>再去检查一下他的申请吧。 => http://www.1kg.org/projects/#{@project.id}/manage </p>\
                                               <br/><p>多背一公斤团队</p>"
                                  )
          message.author_id = 0
          message.to = [@project.user]
          message.save!
          want.html {redirect_to project_path(@project)} 
        end
        
      else
        want.html {@execution.validated? ? render(:feedback) : render(:edit)}
      end
    end
  end

  def validate
    @execution.update_attributes(:validated_at => Time.now, :validated_by_id => current_user.id)
    @execution.allow
    flash[:notice] = "该项目已通过申请"
    message = Message.new(:subject => "你为#{@school.title}申请的公益项目已经通过了审核",
                            :content => "<p>你好，#{@execution.user.login}:</p><br/><p>你为#{@school.title}申请的公益项目“#{@project.title}”已经通过了项目管里员的审核。</p>\
                                         <br/><p>之后该项目的管理者会联系你，确认如何向你提供项目说明中的支持内容：</p>\
                                         <br/><p>而作为项目申请人你需要做到：</p>\
                                         <p> - 在获得支持后，按照你的执行计划按时完成项目的执行。</p>\
                                         <p> - 按照你的反馈计划，按时填写项目反馈，报告项目的进展。</p>\
                                         <br/><p>现在就去你的项目页面看看吧。 => http://www.1kg.org/projects/#{@project.id}/executions/#{@execution.id} </p>\
                                         <br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@execution.user]
    message.save!
    redirect_to manage_project_path(@project)
  end

  def refuse
    @execution.refuse
    @execution.update_attributes(:refused_at => nil, :refused_by_id => current_user.id)
    flash[:notice] = "已拒绝申请"
    redirect_to refuse_letter_project_execution_url(@project,@execution)
  end
  
  def refuse_letter
    flash[:notice] = "申请已拒绝，这是告知项目申请人的站内信，你可以修改此站内信的内容，并说明申请被拒绝的原因。"
    @message = Message.new
    @recipient = @execution.user
  end
  
  def feedback
    respond_to do |want|
      if @execution.validated?
        want.html
      else
        flash[:notice] = "未通过的项目不能写反馈报告"
        want.html { redirect_to @project }
      end
    end   
  end
  
  def info_window
    @community = @execution.community
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  private
  def manage_project_process
    @execution = Execution.find(params[:id])
    @school = @execution.school
    @project = @execution.project
    unless current_user = @execution.user || current_user.admin?
      flash[:notice] = "你没有权限进行此项操作"
      redirect_to project_path(@project)
    end
  end

  def check_permission
    @execution = Execution.find(params[:id])
    @school = @execution.school
    @project = @execution.project
    if @execution.user == current_user
    elsif current_user.admin?
    else
      flash[:notice] = "你没有权限进行此操作"
      redirect_to project_url(@sub_donation)
    end
  end

  def find_execution
    @execution = Execution.validated.find(params[:id])
    @school = @execution.school
    @project = @execution.project
  end
  
end
