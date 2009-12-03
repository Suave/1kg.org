class ActivitiesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_activity,  :except => [:index, :hiring, :ongoing, :over, :new, :create]
  
  def index
    redirect_to root_path
  end
  
  def hiring
    find_activities('hiring')
  end
  
  def ongoing
    find_activities('ongoing')
  end
  
  def over
    find_activities('over')
  end

  def new
    @school=School.find_by_id(params[:school])
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    @activity.save!
    flash[:notice] = "发布成功"
    redirect_to activity_url(@activity)
  end
  
  def edit
  end
  
  def update
    @activity.update_attributes!(params[:activity])
    flash[:notice] = "修改成功"
    redirect_to activity_url(@activity.id)
  end
  
  def destroy
    @activity.update_attributes!(:deleted_at => Time.now)
    flash[:notice] = "删除成功"
    redirect_to root_url
  end
  
  def join
    if @activity.joined?(current_user)
      flash[:notice] = "你已经参加这个活动了, 不用重复点击"
    else
      @activity.participators << current_user
    end
    redirect_to activity_url(@activity)
  end
  
  def quit
    if @activity.joined?(current_user)
      @activity.participators.delete current_user
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
    @comments = @activity.comments.paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
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
                            :content => "#{current_user.login}( #{user_url(current_user)} )邀请您加入#{@activity.title}( #{activity_url(@activity)} )\r\n\r\n快去看看吧\r\n\r\n\r\n多背一公斤客服"
                            )
      message.author_id = 0
      message.to = invited_user_ids
      message.save!
      flash[:notice] = "给#{invited_user_ids.size}位友邻发送了邀请"
    end
    
    redirect_to activity_url(@activity)
  end
  
  private
  def find_activities(status)
    @activities = Activity.send(status.to_sym).available.paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 20)
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