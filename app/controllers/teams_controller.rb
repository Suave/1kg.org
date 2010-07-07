class TeamsController < ApplicationController
  before_filter :find_team, :except => [:new, :create, :index]
  before_filter :login_required, :except => [:index,:show]
  before_filter :check_permission, :only => [:edit,:set_leaders,:searcher_user,:add,:new_activity]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_activity]
  
  def index
    @teams = Team.validated.all
    @myteams = current_user.teams if current_user
  end
  
  def show
    @fellowers = @team.fellowers - @team.leaders
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
  
  def add
    @user = User.find(params[:user_id])
    if  @team.leaders.include?(@user)
      flash[:notice] = "他已经是团队的管理员了"
      redirect_to set_leaders_team_url(@team)
    else
      @user.leaderships.build(:team_id => @team.id,:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id).save
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
  
  def set_leaders
  end
  
  def search_user
    @user = User.find_by_email(params[:email])
    render :set_leaders
  end
  
  def fellow
    #关注团队
    unless @team.fellowers.include?(current_user)
      @team.fellowers << current_user
      flash[:notice] = "关注成功"
      redirect_to team_url(@team)  
    else
      redirect_to team_url(@team)  
    end
  end
  
  def unfellow
    if @team.fellowers.include?(current_user)
      @team.fellowers.delete(current_user)
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
    unless @team.leaders.include?(current_user)
    flash[:notice] = "你没有团队组织权限。"
    redirect_to @team
    end
  end
  
end