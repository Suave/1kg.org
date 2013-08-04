# -*- encoding : utf-8 -*-
require 'json'
class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :info_window, :large_map,:total_topics,:topics,:followers,:intro]
  before_filter :find_school,    :except => [:index,:new,:create,:comments,:check,:total_topics]
  before_filter :check_permission, :only => [:update,:destroy,:managers,:edit]

  def index
    respond_to do |format|
      format.html {
        @map_center = Geo::DEFAULT_CENTER
        @topics = Topic.with_school.find(:all,:limit => 4)
        @recent_school_comments = Topic.find(:all, :conditions => {:boardable_type => 'School'},
      :include => [:user],
      :order => "last_replied_at desc",
      :limit => 4)
        @projects = Project.validated.find :all, :order => "created_at desc",:limit => 2
        
        # 显示需求标签云
        @tags = SchoolNeed.tag_counts[0..50]
      }
      format.json {
        @schools = School.validated
        @schools_json = []
        @schools.each do |school|
          @schools_json << {:i => school.id,
                           :t => school.icon_type,
                           :n => school.title,
                           :a => school.basic.latitude,
                           :o => school.basic.longitude
                          }
        end
        render :json => @schools_json
      }
      format.atom {
        @topics = Topic.find(:all, :conditions => ["boards.talkable_type=?", "SchoolBoard"],
          :include => [:user],
          :order => "topics.created_at desc",
          :limit => 10)
      }
    end
    
  end
  
  def info_window
    
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic

    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def total_topics
    @topics = Topic.with_school.paginate(:page => params[:page], :per_page => 20)
  end

  def unconfirm
    list(false)
  end
  
  def list(validated = true)
    provinces     = Geo.roots
    @all_provinces = []
    @output        = []

    provinces.each do |province|
      areas = province.children
      unless areas.empty?
        schools = School.find(:all, 
                              :conditions => ["schools.deleted_at is NULL and schools.meta=? and schools.validated = ? and schools.geo_id in (?)",false, validated, areas], 
                              :order => "schools.geo_id asc, schools.updated_at desc")

        unless schools.empty?
          @output[province.id] = schools
        end
      end
    end
    provinces.each do |province|
      unless @output[province.id].blank?
        @all_provinces << province
      end
    end
  end
  
  # 给出指定日期的所有学校
  def show_date
    @date = "#{params[:year]}年#{params[:month]}月"
    if params[:valid] == "false"
      @schools = School.show_date(params[:year],params[:month],params[:day],false)
      render :template => "schools/show_invalid"
    else
      @schools = School.show_date(params[:year],params[:month],params[:day],true)
      render :template => "schools/show_valid"
    end 
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "没有找到你查找的学校"
    redirect_to schools_path
  end
  
  def new
    %w(basic traffic need other position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = 'basic'
    if @step == 'basic'
      @school = School.new
    else
      @school = School.validated.find(params[:id])
    end
    
  end
  
  def create
    @school = School.new(params[:school])
    @school.user = current_user
    @school.validated = true
    @school.validated_at = Time.now
    @school.validated_by_id = current_user.id
    respond_to do |format|
      if @school.save
        flash[:notice] = "学校已经提交成功！ 请继续填写其它相关信息.."
        format.html{redirect_to new_school_url(:step => 'traffic',:id => @school.id,:new=> true)}
      else
        flash[:notice] = "请检查所有必填项是否填写正确"
        @step = 'basic'
        format.html{render :action => "new"}
      end
    end
  end
  
  def edit
    %w(basic traffic need other position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = "basic"
    render :action => "edit"
  end
  
  def update
    @school = School.find params[:id]
    respond_to do |format|
      format.html do
        if params[:new] == 'true'
          if params[:step] == 'basic'
            update_info "basic", "traffic", "学校信息提交成功！"
          elsif params[:step] == 'traffic'
            update_info "traffic", "need", "学校交通信息提交成功！"
          elsif params[:step] == 'need'
            update_info "need", "other", "学校需求信息提交成功！"
          elsif params[:step] == 'other'
            update_info "other", "mainphoto", "收集人信息提交成功！"
          elsif params[:step] == 'mainphoto'
            update_main_photo('mainphoto', 'done', "所有学校信息已经完成，谢谢你的提交，作为提交人你自动成为了这所学校的学校大使。<a href='/misc/school-moderator-guide'> 什么是学校大使？ </a>")
          end
        else
          %w(basic traffic need other position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = "basic"
          if @step == 'mainphoto'
            update_main_photo(@step, nil, "你的修改已经保存，可以继续修改其他内容，或 <a href='/schools/#{@school.id}'>回到学校</a>。")
          else
            update_info(@step, nil, "你的修改已经保存，可以继续修改，或 <a href='/schools/#{@school.id}'>回到学校</a>。")
          end
          
        end
        if params[:moderator] == 'add'
          user = User.find params[:uid]
        end
      end
      
      # for drag & drop school marker
      format.js do
        @school.basic.update_attributes( :latitude => params[:latitude], 
                                         :longitude => params[:longitude],
                                         :marked_at => Time.now,
                                         :marked_by_id => current_user.id )
      end
    end
  end
  
  # 标记学校 marker 是正确位置，记录下标记时间和标记人
  def marked
    
    @school.basic.update_attributes!( :marked_at => Time.now,
                                      :marked_by_id => current_user.id )
    flash[:notice] = "已经记录您的标记"
    redirect_to school_url(@school)
  end
  
  def apply
    @message = current_user.sent_messages.build
  end
  
  
  def sent_apply
    @message = current_user.sent_messages.build(params[:message])
    if Visited.find(:first,:conditions => {:user_id => current_user.id,:school_id => @school.id,:status => 1})
      @message = current_user.sent_messages.build(params[:message])
      moderators = @school.managers.map(&:login)
      html = "<br/><br/><br/>
              <span>申请的学校是#{@school.title}(http://www.1kg.org/schools/#{@school.id})</span><br/>
              <span>现有的学校大使是: #{moderators}</span><br/>
              <span>如果你同意这份申请，请到添加大使页面( http://www.1kg.org/schools/#{@school.id}/managerss )添加这个用户</span>"
      @message.content += html
      @message.recipients = (@school.managers + User.admins).uniq
      if @message.save
        flash[:notice] = "申请已发出，请等待#{User.moderators_of(@school).nil?? '学校管理员' : '其他学校大使或学校管理员'}的确认。"
        redirect_to school_url(@school)
      else	    
        render :action => "apply"
      end
    else
      flash[:notice] = "你还没有去过这所学校，不能申请成为学校大使"
      render :action => "apply"
    end
  end
  
  # 未标记学校列表
  def todo
    @geos = Geo.roots
    @schools = School.validated.find :all, :conditions => "marked_at is null", 
                                           :joins => "left join school_basics on schools.id = school_basics.school_id", 
                                           :order => "geo_id asc"
  end
  
  def large_map
    
    @map_center = [@school.basic.latitude, @school.basic.longitude, 7]
    @edit = params[:edit]
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def photos
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
      
    @photos = @school.photos.paginate(:page => params[:page], :per_page => 20)
  end

  def topics
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
      
    @topics = @school.topics.paginate(:page => params[:page], :per_page => 20)
  end


  # 改版学校页面
  def show
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
    
    @school.hit!
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic
    @followers = @school.interestings
    @managers = @school.managers
    @topics = @school.topics.find(:all, :order => "created_at desc", :limit => 5,:include => [:user,:tags])
    @photos = @school.photos.find(:all, :order => "created_at desc", :limit => 6,:include => [:user])
    @main_photo = @school.photos.find_by_id @school.main_photo_id
    
    @activities = Activity.find(:all,:conditions => {:school_id => @school.id},:include => [:user])
    @status = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id]) unless current_user.blank?
    
    @executions = @school.executions.validated.find(:all,:limit => 3)
    @co_donations = @school.co_donations.validated.find(:all,:limit => 3)
  end
  
  def destroy
    respond_to do |format|
      if current_user.owned_by?(current_user)
        @school.destroy
        flash[:notice] = "成功删除学校"
      else
        flash[:notice] = "对不起，只有学校管理员可以删除学校"
      end
      
      format.html{redirect_to schools_url}
    end
  end
  
  def validate
    if current_user.school_moderator?
      if params[:t] == 'add'
        @school.update_attributes!(:validated => true, :validated_at => Time.now, :validated_by_id => current_user.id )
        flash[:notice] = "已经通过验证"
      elsif params[:t] == 'remove'
        @school.update_attributes!(:validated => false, :validated_at => Time.now, :validated_by_id => current_user.id )
        flash[:notice] = "已经取消验证"
      else
        flash[:notice] = "错误"
      end
    else
      flash[:notice] = "对不起，只有学校管理员可以进行此操作"
    end          
    redirect_to school_url(@school)
  end
  
  def visited
    begin
      if @school.visited?(current_user) == false
        Visited.create!(:user_id => current_user.id,
                        :school_id => @school.id,
                        :status => Visited.status('visited'),
                        :notes => params[:visited][:notes],
                        :visited_at => params[:visited][:visited_at]
                       )
        else
        visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
        visited.update_attributes!(:status => Visited.status('visited'),
                                   :notes => params[:visited][:notes],
                                   :visited_at => params[:visited][:visited_at]
                                  )  
      end
      if params[:callback].nil?
      redirect_to school_url(@school)
      else
      render :action => params[:callback]
      end
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请正确填写日期，去过的日期不能在今天之后，格式为 xxxx-xx-xx(年-月-日)'
      if params[:callback].nil?
      redirect_to school_url(@school)
      else
      render :action => params[:callback]
      end
      
    end
  end
 
  def wanna
    begin
      if @school.visited?(current_user) == false
        Visited.create!(:user_id => current_user.id,
                        :school_id => @school.id,
                        :status => Visited.status('wanna'),
                        :notes => params[:visited][:notes],
                        :visited_at => params[:visited][:visited_at]
                       )
      
      else
        visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
        visited.update_attributes!(:status => Visited.status('wanna'),
                                   :notes => params[:visited][:notes],
                                   :visited_at => params[:visited][:visited_at]
                                  )
      end
      redirect_to school_url(@school)
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请正确填写日期，要去的日期必需在今天之后，格式为 xxxx-xx-xx(年-月-日)'
      redirect_to school_url(@school)
    end
  end
  
  def interest
    unless @school.visited?(current_user)
      Visited.create!(:user_id => current_user.id, :school_id => @school.id, :status => Visited.status('interesting'))
      Following.create!(:follower_id => current_user.id, :followable_id => @school.id, :followable_type => 'School')
    else
      flash[:notice] = "你已经选去过或想去这所学校了"
    end
    redirect_to school_url(@school)
  end
  
  def novisited
    visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
    visited.destroy if visited
    following = current_user.followings.find(:first, :conditions => {:followable_id => @school.id, :followable_type => 'School'})
    following.destroy if following
    redirect_to school_url(@school)
  end
  
  # 学校管理员列表
  def managers
    @managements = @school.managements 
    @candidates = @school.visitors - @managements.map(&:user)
  end
  
  def manage
    @user = User.find params[:user]
    if params[:type] == "add"
      @user.roles << Role.find_by_identifier("roles.school.moderator.#{@school.id}")
      message = Message.new(:subject => "恭喜您成为#{@school.title}的学校大使",
                            :content => "<p>你好，#{@user.login}:</p><br/><p>祝贺您成为#{@school.title}学校大使！</p><p>作为#{@school.title}的学校大使，您可以：</p><p> - 编辑、更新学校信息；</p><p> - 添加其他去过学校的用户为学校大使；</p><p> - 为学校申请1KG.org项目，解决学校的需求问题等；</p><p> - 提高学校活跃度，吸引更多的用户关注学校，为学校获取更多的资源。</p><br/><p>现在就进入#{@school.title}（ #{url_for(@school)} ）看看吧。</p><br/><p>多背一公斤团队</p>"
                            )
      message.author_id = 0
      message.to = [@user.id]
      message.save!
      flash[:notice] = "已将 #{@user.login} 设置为 #{@school.title} 的学校大使"
      redirect_to moderator_school_url(@school)

    elsif params[:type] == "remove"
      @user.roles.delete(Role.find_by_identifier("roles.school.moderator.#{@school.id}"))
      flash[:notice] = "已经取消 #{@user.login} 的学校大使身份"
      redirect_to moderator_school_url(@school)
    end
  end
  
  def setphoto
      @school.main_photo = Photo.find_by_id(params[:p].to_i)
      @school.save
      flash[:notice] = "学校主照片设置成功"
      redirect_to school_url(@school)
  end
  
  def check
    @school = School.find_similiar_by_geo_id(params[:title], params[:geo_id])
    respond_to do |format|
      format.html {
        render :text => @school.nil? ? '0' : 
          %(<span class='formError'><img src="/images/unchecked.gif" />#{@school.geo.name}已经有了一所<a href='/schools/#{@school.id}/'>#{@school.title}</a></span>)
      }
    end
  end
  
  def followers
    @followers = @school.interestings
  end
  
  def intro
    @basic = @school.basic
    @text = @basic.intro
    if @text.blank?
      @text = "#{@school.title}的情况："  
      @text += "#{@basic.level_amount}个年级," unless @basic.level_amount.blank?
      @text += "#{@basic.class_amount}个班级," unless @basic.class_amount.blank?
      @text += "#{@basic.student_amount}名学生," unless @basic.student_amount.blank?
      @text += "#{@basic.teacher_amount}名老师。" unless @basic.teacher_amount.blank?
      @text += "#{radio_value @basic.has_library}"
      @text += "#{@basic.book_amount}本" if ! @basic.book_amount == 0
      @text += "图书，"
      @text += "#{radio_value @basic.has_pc}"
      @text += "#{@basic.pc_amount}台" if ! @basic.pc_amount == 0
      @text += "电脑，" 
      @text += "#{'不' if @basic.has_internet == 0}能上网。"
      @text += ""
    end
    render :text => @text
  end
  
  private
  
  def radio_value(value)
    result = %w(没有 有 未知)
    value.blank? ? "未知" : result[value]
  end
  
  def find_school
    @school = School.validated.find(params[:id])
  end
  
  def check_permission
    if @school.managed_by?(current_user) or current_user.admin?
    else
      flash[:notice] = "为了保证学校信息真实准确，只有学校大使才能修改学校信息，成为学校大使很简单，=> <a href='#{apply_school_url(@school)}'>点击这里</a>"
      redirect_to school_url(@school)
    end
  end
  
  def update_main_photo(current_step, next_step, msg)
    @photo = current_user.photos.build(params[:school][:main_photo_attributes])
    if @photo.image_file_name.nil?
      @photo = Photo.find_by_id params[:school][:main_photo_id]
      @school.main_photo = @photo 
      @school.save
      flash[:notice] = msg
      next_step == "done" ? redirect_to(school_url(@school)) : redirect_to(edit_school_url(@school, :step => next_step))
    else
      begin
      @photo.save!
        @school.main_photo = @photo
        @school.save
        flash[:notice] = msg
        if next_step
          next_step == "done" ? redirect_to(school_url(@school)) : redirect_to(new_school_url(@school, :step => next_step))
        else
          redirect_to(edit_school_url(@school, :step => currnet_step))
        end
      rescue
        flash[:notice] = "图片格式有误，请使用 jpg,png,gif 等常见图片格式"
        render :action => "edit"
      end
    end
  end
  
  def update_info(current_step, next_step, msg)
    begin
      @school.update_attributes!(params[:school])
      flash[:notice] = msg
        if next_step
          next_step == "done" ? redirect_to(school_url(@school)) : redirect_to(new_school_url(:step => next_step,:id => @school.id,:new => true))
        else
          if current_step == "need"
            @school.need.update_attributes!(:updated_at => Time.now)
          elsif current_step == "basic"
            @school.basic.update_attributes!(:updated_at => Time.now)
          end
          redirect_to(edit_school_url(@school, :step => current_step))
        end
      
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请检查所有必填项是否填写正确'
      if next_step
        @step = current_step
        render :action => "new"
      else
        @step = current_step
        render :action => "edit"
      end
    end
  end
  
end
