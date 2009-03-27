class GroupsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_group, :except => [:index, :create]
  
  
  def index
    @groups = Group.find :all, :order => "created_at desc"
  end
  
  def new
    
  end
  
  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    @group.save!
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
    @board = @group.discussion.board
    @topics = @board.latest_topics
  end
  
  def join
    if @group.joined?(current_user)
      flash[:notice] = "你已经加入这个小组了"
    else
      @group.members << current_user
    end
    redirect_to group_url(@group)
  end
  
  def quit
    if @group.creator == current_user
      flash[:notice] = "你是小组创建人, 不能退出该组"
    elsif @group.joined?(current_user)
      @group.members.delete current_user
    else
      flash[:notice] = "你没有加入这个小组"
    end
    redirect_to group_url(@group)
  end

  def new_topic
    unless @group.members.include?(current_user)
      flash[:notice] = "只有小组成员才能发起话题"
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
    
    redirect_to manage_group_url @group
  end
  

  private
  def find_group
    @group = params[:id] ? Group.find(params[:id]) : Group.new
  end
  
end