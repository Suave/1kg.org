require 'json'
class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :info_window, :large_map,:lei]
  
  skip_filter :verify_authenticity_token, :only => [:update]
  
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html {
        @photos = Photo.with_school.find(:all,:limit => 10,:order => "created_at desc", :group => "school_id")
        #@recent_schools = School.recent_upload.validated.include([:user, :geo])
        @recent_school_comments = Topic.find(:all, :conditions => ["boards.talkable_type=?", "SchoolBoard"],
      :include => [:user, :board],
      :order => "last_replied_at desc",
      :limit => 6)
        
        # 显示需求标签云
        @tags = SchoolNeed.tag_counts[0..50]
        @activities_for_school = Activity.ongoing.find(:all,
                                                       :conditions => "School_id is not null",
                                                       :order => "created_at desc, start_at desc",
                                                       :limit => 5,
                                                       :include => [:main_photo, :school])
        # 显示最新用户动态
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
    end
    
  end
  
  def info_window
    @school = School.find(params[:id])
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
=begin  
  def all
    redirect_to geos_path
  end
=end

  def comments
    @comments = Topic.latest_updated_with_pagination_in SchoolBoard, params[:page]
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
  
  def archives
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
    @school = School.new
    @step = 'basic'
  end
  
  def create
    @school = School.new(params[:school])
    @school.user = current_user
    @school.validated = true
    @school.validated_at = Time.now
    @school.validated_by_id = current_user.id
    respond_to do |format|
      if @school.save
        flash[:notice] = "学校提交成功！请继续填写学校交通信息.."
        format.html{redirect_to edit_school_url(@school, :step => 'traffic')}
      else
        flash[:notice] = "请检查所有必填项是否填好"
        @step = 'basic'
        format.html{render :action => "new"}
      end
    end
  end
  
  def edit
    @school = School.find(params[:id])
    %w(basic traffic need other position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = "basic"
    render :action => "edit_#{@step}"
  end
  

  def update
    @school = School.find params[:id]
    respond_to do |format|
      format.html do
        if params[:step] == 'basic'
          update_info "basic", "traffic", "学校基本信息修改成功！"
        elsif params[:step] == 'traffic'
          update_info "traffic", "need", "学校交通信息修改成功！"
        elsif params[:step] == 'need'
          update_info "need", "other", "学校需求信息修改成功！"
        elsif params[:step] == 'other'
          update_info "other", "mainphoto", "收集人信息修改成功！"
        elsif params[:step] == 'mainphoto'
          update_info "mainphoto", "done", "学校信息修改完成！"
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
    @school = School.find(params[:id])
    @school.basic.update_attributes!( :marked_at => Time.now,
                                      :marked_by_id => current_user.id )
    flash[:notice] = "已经记录您的标记"
    redirect_to school_url(@school)
  end
  
  def apply
    @school = School.find(params[:id])
    @message = current_user.sent_messages.build
  end
  
  def sent_apply
    @school = School.find(params[:id])
    @message = current_user.sent_messages.build(params[:message])
    if Visited.find(:first,:conditions => {:user_id => current_user.id,:school_id => @school.id,:status => 1})
      @message = current_user.sent_messages.build(params[:message])
      moderators = User.moderators_of(@school).map{|m| "#{m.login}"}
      html = "<br/><br/><br/>
              <span>申请的学校是#{@school.title}(http://www.1kg.org/schools/#{@school.id})</span><br/>
              <span>现有的学校大使是 #{moderators}</span><br/>
              <span>如果你同意这份申请，请到添加大使页面( http://www.1kg.org/schools/#{@school.id}/moderator )添加这个用户</span>"
      @message.content += html
      @message.recipients = (User.moderators_of(@school) + User.school_moderators).uniq
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
    @school = School.find(params[:id])
    @map_center = [@school.basic.latitude, @school.basic.longitude, 7]
    
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def photos
    @school = School.find(params[:id])
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
      
    @photos = @school.photos.paginate(:page => params[:page], :per_page => 20)
  end

  def shares
    @school = School.find(params[:id])
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
      
    @shares = @school.shares.paginate(:page => params[:page], :per_page => 20)
  end

  def shares
    @school = School.find(params[:id])
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
      
    @shares = @school.shares.paginate(:page => params[:page], :per_page => 20)
  end

  # 改版学校页面
  def show
    @school = School.find(params[:id])
    @school.hit!
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic
    @donation = Requirement.find(:all,:conditions => {:status => "1"}).map(&:school).include?(@school)
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
    
    @followers = @school.interestings
    @moderators = User.moderators_of(@school)
    @shares = @school.shares.find(:all, :order => "updated_at desc", :limit => 5,:include => [:user,:tags])
    @photos = @school.photos.find(:all, :order => "updated_at desc", :limit => 6,:include => [:user, :school, :activity])
    @main_photo = @school.photos.find_by_id @school.main_photo_id
    
    @activities = Activity.find(:all,:conditions => {:school_id => @school.id},:include => [:user])
    @visits = Visited.find(:all,:conditions => {:school_id => @school.id,:status => 1},:order => "created_at DESC",:include => [:user])
    @wannas = Visited.find(:all,:conditions => {:school_id => @school.id,:status => 3},:order => "wanna_at ASC",:include => [:user])
    @status = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id]) unless current_user.blank?
    
    @board = SchoolBoard.find(:first, :conditions => {:school_id => @school.id})
    unless @board.blank?
      @board = @board.board
      @topics = @board.latest_topics
    end
  end
  
  def destroy
    @school = School.find(params[:id])
    
    respond_to do |format|
      if current_user.school_moderator? || @school.destroyed_by(current_user)
        @school.destroy
        flash[:notice] = "成功删除学校"
      else
        flash[:notice] = "对不起，只有学校管理员可以删除学校"
      end
      
      format.html{redirect_to schools_url}
    end
  end
  
  def validate
    @school = School.find(params[:id])
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
      @school = School.find(params[:id])
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
      @school = School.find(params[:id])
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
    @school = School.find(params[:id])
    unless @school.visited?(current_user)
      Visited.create!(:user_id => current_user.id, :school_id => @school.id, :status => Visited.status('interesting'))
    else
      flash[:notice] = "你已经选去过或想去这所学校了"
    end
    redirect_to school_url(@school)
  end
  
  def novisited
    @school = School.find(params[:id])
    visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
    visited.destroy if visited
    redirect_to school_url(@school)
  end
  
  # 学校管理员列表
  def moderator
    @school = School.find params[:id]
    if (User.moderators_of(@school) + User.school_moderators).uniq.include?(current_user)
      @moderators = User.moderators_of @school
      @candidates = @school.visitors - @moderators
    else
      flash[:notice] = "你没有添加大使的权限"
      redirect_to school_url(@school)
    end
  end
  
  def manage
    school = School.find params[:id]
    user = User.find params[:user]
    
    if params[:type] == "add"
      
      user.roles << Role.find_by_identifier("roles.school.moderator.#{school.id}")
      message = Message.new(:subject => "恭喜您成为#{school.title}的学校大使",
                            :content => "<p>#{user.login}，</p><p>祝贺您成为#{school.title}学校大使！</p><p>作为#{school.title}的学校大使，您可以：</p><p> - 编辑、更新学校信息；</p><p> - 添加其他去过学校的用户为学校大使；</p><p> - 为学校申请1KG.org项目，解决学校的需求问题等；</p><p> - 提高学校活跃度，吸引更多的用户关注学校，为学校获取更多的资源。</p><p>现在就进入#{school.title}（ #{url_for(school)} ）看看吧。</p><p>多背一公斤团队</p>"
                            )
      message.author_id = 0
      message.to = [user.id]
      message.save!
      flash[:notice] = "已将 #{user.login} 设置为 #{school.title} 的学校大使"
      redirect_to moderator_school_url(school)

    elsif params[:type] == "remove"
      user.roles.delete(Role.find_by_identifier("roles.school.moderator.#{school.id}"))
      flash[:notice] = "已经取消 #{user.login} 的学校大使身份"
      redirect_to moderator_school_url(school)
    end
  end
  
  def setphoto
    @school = School.find(params[:id])
    if current_user && @school.edited_by(current_user)
      @school.main_photo = Photo.find_by_id(params[:p].to_i)
      @school.save
      flash[:notice] = "学校主照片设置成功"
      redirect_to school_url(@school)
    else
      flash[:notice] = "只有学校大使才可以设置学校主照片"
      redirect_to school_url(@school)
    end
  end
  
  def mainphoto_create
    @school = School.find(params[:id])
    @photo = Photo.new(params[:photo])
    @photo.school_id = @school.id
    @photos = @school.photos
    @photo.user = current_user
    logger.info("PHOTO: #{@photo.inspect}")
    if @photo.filename.nil?
      flash[:notice] = "请选择要上传的照片"
      render :action => "edit_mainphoto"
    else
      begin
      @photo.save!
        if current_user && @school.edited_by(current_user)
          @school.main_photo = @photo
          @school.save
          flash[:notice] = "学校主照片设置成功"
          redirect_to school_url(@school)
        else
          flash[:notice] = "你没有设置此学校主照片的权限"
          redirect_to school_url(@school)
        end
      rescue
        flash[:notice] = "图片格式有误，请使用 jpg,png,gif 等常见图片格式"
        render :action => "edit_mainphoto"
      end
    end
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
  
  private
  
  def update_info(current_step, next_step, msg)
    begin
      @school.update_attributes!(params[:school])
      flash[:notice] = msg
      next_step == "done" ? redirect_to(school_url(@school)) : redirect_to(edit_school_url(@school, :step => next_step))
      
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请检查所有必填项是否填好'
      render :action => "edit_#{current_step}"
    end
  end
  
end