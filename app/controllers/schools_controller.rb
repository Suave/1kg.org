require 'json'
class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :info_window, :large_map,:lei]
  
  skip_filter :verify_authenticity_token, :only => [:update]
  
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html {
        @photos = Photo.latest.include([:school, :user])
        #@recent_schools = School.recent_upload.validated.include([:user, :geo])
        #@recent_school_comments = Topic.last_10_updated_topics(SchoolBoard)
        
        # 显示需求标签云
        @tags = SchoolNeed.tag_counts[0..50]
      
        @activities_for_travel = Activity.available.ongoing.by_category("公益旅游").find(:all, :order => "created_at desc, start_at desc", :limit => 10)
        
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
        flash[:notice] = "学校基本信息已保存，请继续填写学校交通信息"
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
    %w(basic traffic need other position).include?(params[:step]) ? @step = params[:step] : @step = "basic"
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
          update_info "other", "done", "学校信息修改完成！"
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
  
  #旧版的学校页面
  #def show
  #  @school = School.find(params[:id])
  #  
  #  @school.hit!
  #  
  #  @traffic = @school.traffic
  #  @need = @school.need
  #  @local   = @school.local
  #  @contact = @school.contact
  #  @finder  = @school.finder
  #  @basic = @school.basic
  #  
  #  if @school.nil? or @school.deleted?
  #    render_404 and return
  #  end
  #  
  #  @visitors = @school.visitors
  #  @followers = @school.interestings
  #  @moderators = User.moderators_of(@school)
  #  @shares = @school.shares
  #  @photos = @school.photos.find(:all, :order => "updated_at desc", :limit => 12)
  #  if logged_in?
  #    @visited = Visited.find(:first, :conditions => ["user_id=? and school_id=? and status=?", current_user, @school.id, Visited.status('visited')])
  #  end
  #  
  #  @board = SchoolBoard.find(:first, :conditions => {:school_id => @school.id})
  #  unless @board.blank?
  #    @board = @board.board
  #    @topics = @board.latest_topics
  #  end 
  #end

  # 学校页面改版
  def show
    @school = School.find(params[:id])
    @school.hit!
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
    
    @followers = @school.interestings
    @moderators = User.moderators_of(@school)
    @shares = @school.shares
    @photos = @school.photos.find(:all, :order => "updated_at desc", :limit => 6,:include => [:user, :school, :activity])
    @main_photo = @school.photos.find_by_id @school.main_photo_id
    
    @activity = Activity.find(:all,:conditions => {:school_id => @school.id},:include => [:user])
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
      redirect_to school_url(@school)
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请正确填写日期，去过的日期不能在今天之后，格式为 xxxx-xx-xx(年-月-日)'
      redirect_to school_url(@school)
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
    @moderators = User.moderators_of @school
    @candidates = @school.visitors + @school.interestings - @moderators
  end
  
  def manage
    school = School.find params[:id]
    user = User.find params[:user]
    
    if params[:type] == "add"
      
      user.roles << Role.find_by_identifier("roles.school.moderator.#{school.id}")

      message = Message.new(:subject => "恭喜您成为#{school.title}的学校大使",
                            :content => "<p>#{user.login}，</p><p>祝贺您成为#{school.title}学校大使！</p><p>作为#{school.title}的学校大使，您可以：</p><p> - 编辑、更新学校信息；</p><p> - 添加其他去过学校的用户为学校大使；</p><p> - 为学校申请1KG.org项目，解决学校的需求问题等；</p><p> - 提高学校活跃度，吸引更多的用户关注学校，为学校获取更多的资源。</p><p>现在就进入#{school.title}（ <a href='#{url_for(school)}'>#{url_for(school)}</a> ）看看吧。</p><p>多背一公斤团队</p>"
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
      redirect_to school_url(@school)
    else
      flash[:notice] = "只有学校大使才可以设置学校主照片"
      redirect_to school_url(@school)
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