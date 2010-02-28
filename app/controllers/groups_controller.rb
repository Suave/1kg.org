class GroupsController < ApplicationController
  include Util
  
  before_filter :login_required, :except => [:index, :show, :all]
  before_filter :find_group, :except => [:index, :create, :all]
  
  
  def index
    @groups = Group.find :all, :order => "created_at desc", :limit => 12
    @recent_topics_in_all_groups = Topic.latest_updated_in GroupBoard, 15
    if logged_in?
      @my_groups = current_user.joined_groups.paginate(:page => 1, :per_page => 12)
      @recent_topics = current_user.recent_joined_groups_topics
      @participated_topics = current_user.participated_group_topics.paginate(:page => 1, :per_page => 15)
      @submitted_topics = current_user.group_topics.paginate(:page => 1, :per_page => 15)
    end
  end
  
  def all
    @groups = Group.paginate :page => params[:page] || 1, 
                             :conditions => "deleted_at is null", 
                             :order => "created_at desc", 
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
    avatar_convert(:group, :avatar)
    @group = Group.new(params[:group])
    @group.creator = current_user
    @group.save!
    flash[:notice] = "小组创建成功"
    redirect_to group_url(@group)
  end
  
  def edit
    
  end
  
  def update
    avatar_convert(:group, :avatar)
    
    @group.update_attributes!(params[:group])
    flash[:notice] = "小组信息修改成功"
    redirect_to group_url(@group)
  end
  
  def show
    @board = @group.discussion.board
    @topics = @board.topics.find(:all,
                              :order => "updated_at desc",
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

  def new_topic
    unless @group.members.include?(current_user)
      flash[:notice] = "要先加入小组，才能发起话题"
      redirect_to group_url(@group)
    else
      @board = @group.discussion.board
      @topic = Topic.new
      render :template => "/topics/new"
    end
  end
  
  def manage
    @board = @group.discussion.board
    @moderators = User.moderators_of(@board)
    @members = @group.members - @moderators
  end
  
  def moderator
    @board = @group.discussion.board
    @moderators = User.moderators_of(@board)
    moderator_role = Role.find_by_identifier("roles.board.moderator.#{@board.id}")
    
    if params[:add]
      user = User.find(params[:add])
      if @moderators.include?(user)
        flash[:notice] = "#{user.login}已经是组长了"
      else
        user.roles << moderator_role
      end
      
    elsif params[:remove]
      user = User.find(params[:remove])
      if @moderators.include?(user)
        if @moderators.size > 1
          user.roles.delete moderator_role
        else
          flash[:notice] = "#{user.login}是唯一的组长, 不能取消"
        end
      else
        flash[:notice] = "#{user.login}不是组长"
      end
      
    end
    
    redirect_to(manage_group_url(@group))
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
                            :content => "<p>#{current_user.login}( #{user_url(current_user)})邀请您加入#{@group.title}小组( #{group_url(@group)})</p><p>快去看看吧</p><p>多背一公斤团队</p>"
                            )
      message.author_id = 0
      message.to = invited_user_ids
      message.save!
      flash[:notice] = "给#{invited_user_ids.size}位友邻发送了邀请"
    end
    
    redirect_to group_url(@group)
  end
  
  private
  def find_group
    @group = params[:id] ? Group.find(params[:id]) : Group.new
  end
  
end