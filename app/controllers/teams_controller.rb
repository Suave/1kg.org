# -*- encoding : utf-8 -*-
class TeamsController < ApplicationController
  before_filter :find_team, :except => [:new, :create, :index]
  before_filter :login_required, :except => [:index,:show,:large_map]
  before_filter :check_permission, :only => [:edit,:update,:managers,:searcher_user,:add,:new_activity]
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_activity]
  
  def index
    @teams = Team.validated.all
    @activities = Activity.ongoing.find(:all,:conditions => "team_id is not null",:limit => 10,:order => "created_at desc")
    @topics =  Topic.find(:all,:limit => 10, :conditions => ["boardable_type = ?","Team"],:order => "last_replied_at desc")
    @myteams = Management.find(:all,:conditions => {:user_id => current_user.id,:manageable_type => 'Team'}).map(&:manageable) if current_user
    @followingteams = (Follow.teams.find(:all,:conditions => {:follower_id => current_user.id}).map(&:followable) - @myteams) if current_user
  end
  
  def show
    @schools = @team.helped_schools
    @followers = @team.followers
    @photos = @team.activities.map(&:photos).flatten[0..7]
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
  
  def managers
    @managements = @team.managements
    @followers = @team.followers - @team.managers
    @mymanagement = current_user.managements.find(:first,:conditions => {:manageable_id => @team.id,:manageable_type => 'Team'})
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
 
  def search_user
    @followers = @team.followers - @team.managers
    @user = User.find_by_email(params[:email])
    render :managers
  end  

  private
  
  def find_team
    @team = Team.validated.find(params[:id])
  end
  
  def check_permission
    unless @team.managers.include?(current_user) || current_user.admin?
    flash[:notice] = "你没有团队组织权限。"
    redirect_to @team
    end
  end
  
end
