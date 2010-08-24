class ActivitiesController < ApplicationController
  before_filter :login_required, :except => [:index, :show,:ongoing, :over,:category,:with_school,:total_shares,:info_window,:by_geo]
  before_filter :find_activity,  :except => [:index, :ongoing, :over, :new, :create,:category,:with_school,:total_shares,:by_geo]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @map_center = Geo::DEFAULT_CENTER
    @json = []
    Activity.ongoing.find(:all,:conditions => ["arrival_id > ?", 0]).each do |activity|
      @json << {:i => activity.arrival.id,
                       :t => activity.category,
                       :n => activity.title,
                       :a => activity.arrival.latitude,
                       :o => activity.arrival.longitude
                       }
    end
    @activities_hash = {}
    @activities = Activity.available.ongoing.find(:all,:limit => 60, :order => "created_at desc", :conditions => ['created_at > ?', Time.now - 1.month], :include => [:main_photo,:departure, :arrival])
    @activities_hash = @activities.group_by(&:category)
    @shares = Share.with_activity.find(:all,:limit => 6)
    @participated = current_user.participated_activities.find(:all, :limit => 4) if logged_in?

    respond_to do |wants|
      wants.html 
      wants.atom
    end
  end
  
  def category
    @category_hash = {'travel' => 0,'donation' => 1,'teach' => 2,'other' => 3, 'city' => 4, 'online' => 5}
    render_404 if @category_hash[params[:c]].nil?
    @category = @category_hash[params[:c]]
    
    if params[:over] == "true"
      @activities = Activity.over.find(:all,:conditions => {:category => @category},:include => [:main_photo, :departure, :arrival],:order => "end_at desc").paginate(:page => params[:page] || 1,
                                :per_page => 14)
      @over = params[:over]
    else
      @activities = Activity.ongoing.find(:all,:conditions => {:category => @category},:include => [:main_photo, :departure, :arrival],:order => "created_at desc").paginate(:page => params[:page] || 1,
                                :per_page => 14)
      end
  end
  
  def with_school
    @activities = Activity.ongoing.find(:all,:conditions => "School_id is not null",:include => [:main_photo, :departure, :arrival]).paginate(:page => params[:page] || 1,
                                  :order => "created_at desc, start_at desc",
                                  :per_page => 14)
  end
  
  def total_shares
    @shares = Share.with_activity.paginate(:page => params[:page], :per_page => 20)
    @title = @page_title = "所有活动分享"
  end
  
  def ongoing
    find_activities('ongoing')
  end
  
  def over
    @archives = Activity.archives
    begin
      if Time.now.beginning_of_month == Time.mktime(params[:date][0,4],params[:date][5,2])
        @activities = Activity.find(:all, :order => "participations_count desc",:conditions => {:end_at => Time.now.beginning_of_month..1.day.ago}).paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 10)
        @date = Time.now
      else
        @date = Time.mktime(params[:date][0,4],params[:date][5,2])
        @activities = Activity.find(:all, :order => "participations_count desc",:conditions => {:end_at => @date..@date.end_of_month}).paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 10)
      end
    rescue
    @activities = Activity.find(:all, :order => "participations_count desc",:conditions => {:end_at => Time.now.beginning_of_month..1.day.ago}).paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 10)
    @date = Time.now
    if @activities.empty?
      @activities = Activity.find(:all, :order => "participations_count desc",:conditions => {:end_at => 1.month.ago.beginning_of_month..1.day.ago}).paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 10)
      @date = 1.month.ago
    end
    end
  end

  
  def new
    @school=School.find_by_id(params[:school])
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    @activity.save!
    @activity.participators << current_user
    flash[:notice] = "活动发布成功，作为活动发起人你会自动“参加“这个活动，请上传活动主题图片，或者 " + " <a href='#{activity_url(@activity)}'>跳过此步骤</a>。"
    redirect_to mainphoto_activity_url(@activity)
  end
  
  def mainphoto
    @photo = Photo.new
    @photo.activity = @activity
  end
  
  def edit
  end
  
  def mainphoto_create
    @photo = Photo.new(params[:photo])
    @photo.user = current_user
    logger.info("PHOTO: #{@photo.inspect}")
    if @photo.filename.nil?
      render :action => 'mainphoto'
    else
      @photo.save!
      if current_user && @activity.edited_by(current_user)
        @activity.main_photo = @photo
        @activity.save
        flash[:notice] = "活动主题图设置成功"
        redirect_to activity_url(@activity)
      else
        flash[:notice] = "你不可以设置此活动的主题图"
        redirect_to activity_url(@activity)
      end
    end
  end
  
  def update
    @activity.update_attributes!(params[:activity])
    flash[:notice] = "修改成功"
    redirect_to activity_url(@activity.id)
  end
  
  def destroy
    @activity = Activity.find(params[:id])    
    respond_to do |format|
      if current_user.admin?
        @activity.destroy
        flash[:notice] = "成功删除活动"
      else
        flash[:notice] = "对不起，只有管理员才可以删除活动"
      end 
      format.html{redirect_to activities_url}
    end
  end
  
  def join
    if @activity.joined?(current_user)
      flash[:notice] = "你已经参加这个活动了, 不用重复点击"
    else
      @activity.participators << current_user
      
      # 生成动态
      current_user.feed_items.create(:user_id => current_user.id, :category => 'join_activity',
                  :item_id => @activity.id, :item_type => 'Activity')
    end
    redirect_to activity_url(@activity)
  end
  
  def quit
    if @activity.joined?(current_user)
      @activity.participators.delete current_user
      current_user.feed_items.create(:user_id => current_user.id, :category => 'quit_activity',
                  :item_id => @activity.id, :item_type => 'Activity')
    else
      flash[:notice] = "你没有参加过这个活动"
    end
    redirect_to activity_url(@activity)
  end

  def show
    unless @activity.deleted_at.nil?
      flash[:notice] = "该活动已删除"
      redirect_to activities_url
    end
    @shares = @activity.shares
    @photos = @activity.photos.find(:all, :order => "updated_at desc",:include => [:user, :school, :activity])
    @comments = @activity.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def stick
    @activity.toggle!(:sticky)
    flash[:notice] = "本活动已经置顶" if @activity.sticky?
    flash[:notice] = "本活动已经取消置顶" unless @activity.sticky?
    redirect_to activity_url(@activity)
  end
  
  def invite
    @friends = current_user.neighbors - @activity.participators
  end
  
  def send_invitation
    if params[:invite].blank?
      flash[:notice] = "请选择邀请对象"
    else
      invited_user_ids = params[:invite].collect {|k,v| v.to_i}
      message = Message.new(:subject => "#{current_user.login}邀请您参加#{@activity.title}",
                            :content => "<p>#{current_user.login}(#{user_url(current_user)})邀请您加入#{@activity.title}(#{activity_url(@activity)})</p><p><br/>快去看看吧!</p><p><br/>多背一公斤团队</p>"
                            )
      message.author_id = 0
      message.to = invited_user_ids
      message.save!
      flash[:notice] = "给#{invited_user_ids.size}位用户发送了邀请"
    end
    
    redirect_to activity_url(@activity)
  end
  
  def setphoto
    @activity = Activity.find(params[:id])
    if current_user && @activity.edited_by(current_user)
      @activity.main_photo = Photo.find_by_id(params[:p].to_i)
      @activity.save
      flash[:notice] = "活动主题图设置成功"
      redirect_to activity_url(@activity)
    else
      flash[:notice] = "你不可以设置此活动的主题图"
      redirect_to activity_url(@school)
    end
  end
  
  def info_window
    @geo = Geo.find params[:id]
    @activities = Activity.ongoing.find(:all,:conditions => {:arrival_id => @geo.id},:limit => 3)
    respond_to do |format|
      format.html {render :layout => false}
    end
  end

  def by_geo
    @geo = Geo.find params[:id]
    @activities = Activity.ongoing.find(:all,:conditions => {:arrival_id => @geo.id})
    respond_to do |format|
      format.html
    end
  end
  
  private
  def find_activities(status)
    @activities = Activity.send(status.to_sym).available.paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 10)
  end
  
  def find_activity
    begin  
      @activity = Activity.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "没有找到这个活动, 可能已被管理员删除"
      redirect_to root_url
    end  
  end
  
end