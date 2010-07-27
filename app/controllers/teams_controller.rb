class TeamsController < ApplicationController
  before_filter :find_team, :except => [:new, :create, :index]
  before_filter :login_required, :except => [:index,:show,:large_map]
  before_filter :check_permission, :only => [:edit,:update,:set_leaders,:searcher_user,:add,:new_activity]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_activity]
  
  def index
    @teams = Team.validated.all
    @activities = Activity.ongoing.find(:all,:conditions => "team_id is not null",:limit => 10,:order => "created_at desc")
    @topics =  Topic.find(:all,:limit => 10, :conditions => ["boards.talkable_type = ?","Team"],:include => [:board],:order => "last_replied_at desc")
    @myteams = Team.validated.find(:all,:conditions => {:user_id => current_user.id}) if current_user
  end
  
  def show
    @followers = @team.followers - @team.leaders
    @schools = @team.helped_schools
    @photos = Photo.find(:all,:include => [:activity],:conditions => ["activities.team_id = ?",@team.id]) #使用性能较好的写法
    @map_center = @team.latitude?? [@team.latitude, @team.longitude, (@team.zoom_level - 1)] : [@team.geo.latitude, @team.geo.longitude, 6]
    @json = []
    @schools.compact.each do |school|
      next if school.basic.blank?
      @json << {:i => school.id,
                       :t => school.icon_type,
                       :n => school.title,
                       :a => school.basic.latitude,
                       :o => school.basic.longitude
                       }
    end
  end
  
  def large_map
    @edit = params[:edit]
    @schools = @team.helped_schools
    @json = []
    @map_center = @team.latitude?? [@team.latitude, @team.longitude, @team.zoom_level] : [@team.geo.latitude, @team.geo.longitude, 7]
    @schools.compact.each do |school|
      next if school.basic.blank?
      @json << {:i => school.id,
                       :t => school.icon_type,
                       :n => school.title,
                       :a => school.basic.latitude,
                       :o => school.basic.longitude
                       }
    end    
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  

  def new
    @team = Team.new
  end
  
  def new_activity
    @activity = Activity.new(:team_id => @team.id,:by_team => true)
  end
  
  def create_activity
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    @activity.team = @team
    @activity.by_team = true
    if @activity.save
      @activity.participators << current_user
      flash[:notice] = "活动发布成功，作为活动发起人你会自动“参加“这个活动，请上传活动主题图片，或者 " + " <a href='#{activity_url(@activity)}'>跳过此步骤</a>。"
      redirect_to mainphoto_activity_url(@activity)
    else
      render "new_activity"
    end
  end
  
  def create
    @team = Team.new(params[:team])
    @team.user = current_user
    @team.latitude
    
    respond_to do |want|
      if @team.save
        flash[:notice] = "你的团队申请已经发出，我们会尽快审核你的申请，一经通过会有站内信通知你，注意查收。"
        want.html { redirect_to teams_url }
      else
        want.html { render 'new' }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |wants|
      wants.html do
        if @team.update_attributes(params[:team])
          flash[:notice] = "团队信息修改成功"
          wants.html {redirect_to team_url(@team)}
        else
          wants.html {render 'edit'}
        end
      end
      
      wants.js do
        @team.update_attributes(:latitude => params[:latitude],:longitude => params[:longitude],:zoom_level => params[:zoom_level])
        wants.html {render_404}
      end
    end
  end
  
  def new_activity
    @activity = Activity.new
  end
  
  def add
    @user = User.find(params[:user_id])
    if  @team.leaders.include?(@user)
      flash[:notice] = "他已经是团队的管理员了"
      redirect_to set_leaders_team_url(@team)
    else
      @user.leaderships.build(:team_id => @team.id).save
      @team.followers << @user
      message = Message.new(:subject => "你成为了#{@team.name}的管理员",
                          :content => "<p>你好,#{@user.login}:</p><br/><p>祝贺你成为#{@team.name}的管理员。<br/>成为管理员后，你可以编辑团队的信息，并可以在团队页面以团队的名义发起活动。<br/>快去看看吧 => #{team_url(@team)}</p> <br/><p>多背一公斤团队</p>"
                          )
      message.author_id = 0
      message.to = [@user]
      message.save!
    
      flash[:notice] = "#{@user.login}成为了团队的管理员。"
      redirect_to set_leaders_team_url(@team)
    end
  end
  
  def leave
    if  @team.leaders.size == 1
      flash[:notice] = "你是目前团队唯一的管理员，就不能退出啦"
      redirect_to set_leaders_team_url(@team)
    else
      current_user.leaderships.find_by_team_id(@team).delete
      flash[:notice] = "你现在不是#{@team.name}的管理员了。"
      redirect_to team_url(@team)
    end
  end
  
  def set_leaders
    @followers = @team.followers - @team.leaders
  end
  
  def search_user
    @followers = @team.followers - @team.leaders
    @user = User.find_by_email(params[:email])
    render :set_leaders
  end
  
  def follow
    #关注团队
    unless @team.followers.include?(current_user)
      @team.followers << current_user
      flash[:notice] = "关注成功"
      redirect_to team_url(@team)  
    else
      redirect_to team_url(@team)  
    end
  end
  
  def unfollow
    if @team.followers.include?(current_user)
      @team.followers.delete(current_user)
      flash[:notice] = "已经取消"
      redirect_to team_url(@team)  
    else
      redirect_to team_url(@team)  
    end
  end
  
  private
  
  def find_team
    @team = Team.validated.find(params[:id])
  end
  
  def check_permission
    unless @team.leaders.include?(current_user) || current_user.admin?
    flash[:notice] = "你没有团队组织权限。"
    redirect_to @team
    end
  end
  
end