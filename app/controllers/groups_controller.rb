class GroupsController < ApplicationController
  before_filter :login_required, :only => [:join, :quit, :new_topic]
  before_filter :find_group, :except => [:index]
  def index
    
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
  

  private
  def find_group
    @group = Group.find(params[:id])
  end
  
end