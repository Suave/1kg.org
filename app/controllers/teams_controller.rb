class TeamsController < ApplicationController
  before_filter :find_team, :except => [:new, :create, :index]
  before_filter :login_required, :except => [:index,:show]
  before_filter :check_permission, :only => [:edit,:allow,:refuse,:set_leaders,:searcher_user,:add,:new_activity]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_activity]
  
  def index
    @teams = Team.validated.all
    @myteams = current_user.teams if current_user
  end
  
  def show
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
    respond_to do |want|
      if @team.save
        flash[:notice] = "你的团队申请已经发出，我们会尽快审核你的申请，一经通过会有站内信通知你，注意查收。"
        want.html { redirect_to teams_url }
      else
        want.html { render 'new' }
      end
    end
  end
  
  def update
    @team.update_attributes!(params[:team])
    flash[:notice] = "修改成功"
    redirect_to edit_team_url(@team)
  end
  
  def new_activity
    @activity = Activity.new
  end
  
  def apply
    if  @team.leaders.include?(current_user)
      flash[:notice] = "你已经申请过了，请等待现有的团队组织者的审核，注意查收站内信通知。"
      redirect_to @team
    else
      current_user.leaderships.build(:team_id => @team.id).save
      message = Message.new(:subject => "#{current_user.login}申请成为#{@team.name}的组织者",
                          :content => "<p>你好:</p><br/><p>用户#{current_user.login}( #{user_url(current_user)} )申请成为#{@team.name}的组织者。<br/>你可以在这里通过或拒绝他的申请 => #{set_leaders_team_url(@team)}</p> <br/><p>多背一公斤团队</p>"
                          )
      message.author_id = 0
      message.to = @team.allowed_leaders
      message.save!
        
      flash[:notice] = "你的申请已经发出，现有的团队组织者会收到站内信提醒，尽快审核你的申请。"
      redirect_to @team
    end
  end
  
  def add
    @user = User.find(params[:user_id])
    if  @team.leaders.include?(@user)
      flash[:notice] = "他已经是团队的组织者了"
      redirect_to set_leaders_team_url(@team)
    else
      @user.leaderships.build(:team_id => @team.id,:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id).save
      message = Message.new(:subject => "你成为了#{@team.name}的组织者",
                          :content => "<p>你好,#{@user.login}:</p><br/><p>祝贺你成为#{@team.name}的组织者。<br/>成为组织者后，你可以编辑团队的信息，并可以在团队页面以团队的名义发起活动。<br/>快去看看吧 => #{team_url(@team)}</p> <br/><p>多背一公斤团队</p>"
                          )
      message.author_id = 0
      message.to = [@user]
      message.save!
    
      flash[:notice] = "#{@user.login}成为了团队组织者。"
      redirect_to set_leaders_team_url(@team)
    end
  end
  
  def allow
    @leadership = Leadership.find_by_id(params[:leadership_id].to_i)
    @leadership.update_attributes!(:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id)
    
      message = Message.new(:subject => "你成为了#{@team.name}的组织者",
                          :content => "<p>你好,#{@leadership.user.login}:</p><br/><p>祝贺你成为#{@team.name}的组织者。<br/>成为组织者后，你可以编辑团队的信息，并可以在团队页面以团队的名义发起活动。<br/>快去看看吧 => #{team_url(@team)}</p> <br/><p>多背一公斤团队</p>"
                          )
      message.author_id = 0
      message.to = [@leadership.user]
      message.save!
    
    flash[:notice] = "#{@leadership.user.login}成为了团队组织者。"
    redirect_to set_leaders_team_url(@team)
  end
  
  def refuse
    @leadership = Leadership.find_by_id(params[:leadership_id].to_i)
    @leadership.delete
    
    message = Message.new(:subject => "你加入#{@team.name}组织者的申请被拒绝了",
                          :content => "<p>你好,#{@leadership.user.login}:</p><br/><p>你加入#{@team.name}组织者的申请被拒绝了，可能是因为出于更为谨慎的考虑。<br/>不过没关系，去团队页面看看吧 => #{team_url(@team)}</p> <br/><p>多背一公斤团队</p>"
                          )
      message.author_id = 0
      message.to = [@leadership.user]
      message.save!
    
    flash[:notice] = "拒绝了#{@leadership.user.login}的申请。"
    redirect_to set_leaders_team_url(@team)
  end
  
  def set_leaders
  end
  
  def search_user
    @user = User.find_by_email(params[:email])
    render :set_leaders
  end
  
  private
  
  def find_team
    @team = Team.validated.find(params[:id])
  end
  
  def check_permission
    unless @team.allowed_leaders.include?(current_user)
    flash[:notice] = "你没有团队组织权限。"
    redirect_to @team
    end
  end
  
end