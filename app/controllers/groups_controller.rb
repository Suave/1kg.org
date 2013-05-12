# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :all]
  before_filter :find_group, :except => [:index, :create, :all]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_topic, :new, :create, :edit, :update]
  
  def index
    @recent_topics_in_all_groups = Topic.latest_updated_in Group, 20
    if logged_in?
      @my_recommends = (Group.find(:all,:conditions=>{:geo_id=>current_user.geo_id}).sort!{ |x,y| y.memberships.count <=> x.memberships.count }.map{|a| a unless a.joined?(current_user)}.compact[0...4]+Group.find(:all,:limit=>8,:conditions=>{:geo_id=>0}).sort!{ |x,y| y.memberships.count <=> x.memberships.count }.map{|a| a unless a.joined?(current_user)}.compact[0...8])[0,8]
      @my_groups = current_user.joined_groups.paginate(:page => 1, :per_page => 8)
      @recent_topics = current_user.recent_joined_groups_topics
      @participated_topics = current_user.participated_group_topics.paginate(:page => 1, :per_page => 20)
      @submitted_topics = current_user.group_topics.paginate(:page => 1, :per_page => 20)
    end
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end
  
  def all
    @groups = Group.paginate :page => params[:page] || 1, 
                             :conditions => "deleted_at is null", 
                             :order => "created_at asc", 
                             :per_page => 49
  end
  
  def new
    
  end
  
  def participated
    @title = "我参与的话题"
    @topics = current_user.participated_group_topics.paginate( :page => params[:page] || 1,
                                        :include => [:user],
                                        :per_page => 20
                                      )
    render :template => "/groups/topics"
  end
  
  def submitted
    @title = "我发起的话题"
    @topics = current_user.group_topics.paginate( :page => params[:page] || 1,
                                        :include => [:user],
                                        :per_page => 20
                                      )
    render :template => "/groups/topics"
  end
  
  def create
      @group = Group.new(params[:group])
      @group.creator = current_user
      @group.save
      flash[:notice] = "小组创建成功"
      redirect_to group_url(@group)
  end
  
  def edit
    
  end
  
  def update   
    @group.update_attributes!(params[:group])
    flash[:notice] = "小组信息修改成功"
    redirect_to group_url(@group)
  end
  
  def show
    @topics = @group.topics.find(:all,
                            :order => "created_at desc",
                            :include => [:user],
                            :limit => 10)
  end
  
  def members
  end
  
  def join
    if @group.joined?(current_user)
      flash[:notice] = "你已经加入这个小组了"
    else
      flash[:notice] = "你加入了#{@group.title}小组"
      @group.members << current_user
    end
    redirect_to CGI.unescape(params[:to] || group_url(@group))
  end
  
  def quit
    if @group.creator == current_user
      flash[:notice] = "你是小组创建人, 不能退出该组"
    elsif @group.joined?(current_user)
      @group.members.delete current_user
    else
      flash[:notice] = "你没有加入这个小组"
    end
    redirect_to CGI.unescape(params[:to] || group_url(@group))
  end

  def managers
    @managements = @group.managements
    @managers = @group.managers
    @members = @group.members - @managers
  end
  
  def invite
    @friends = current_user.neighbors - @group.members
  end
  
  def send_invitation
    if params[:invite].blank?
      flash[:notice] = "请选择邀请对象"
    else
      invited_user_ids = params[:invite].collect {|k,v| v.to_i}
      message = Message.new(:subject => "#{current_user.login}邀请您加入#{@group.title}小组",
                            :content => "<p>#{current_user.login}( #{user_url(current_user)})邀请您加入#{@group.title}小组( #{group_url(@group)})</p><br/><p>快去看看吧</p><br/><p>-多背一公斤团队</p>"
                            )
      message.author_id = 0
      message.to = invited_user_ids
      message.save!
      flash[:notice] = "给#{invited_user_ids.size}位用户发送了邀请"
    end
    
    redirect_to group_url(@group)
  end
  
  private
  def find_group
    @group = params[:id] ? Group.find(params[:id]) : Group.new
  end
  
end
