class ActivitiesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  def index
    #deprecated, not use this action
    @status = params[:status].blank? ? "hiring" : params[:status]
    
    if params[:status] == "over"
      # 已结束的活动
      @activities = Activity.find(:all, :conditions => ["done=? or end_at < ?", true, Time.now],
                                        :order => "updated_at desc",
                                        :limit => 15)
                                        
    elsif params[:status] == "ongoing"
      # 进行中的活动
      @activities = Activity.find(:all, :conditions => ["start_at < ? and end_at > ?", Time.now, Time.now],
                                        :order => "updated_at desc",
                                        :limit => 15)
                                        
    else
      # 招募中的
      @activities = Activity.find(:all, :conditions => ["start_at > ?", Time.now],
                                       :order => "updated_at desc",
                                       :limit => 15)
    
    end
    
    # for latest updated activity topics
    #@topics = Topic.last_10_updated_topics(ActivityBoard)
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
    @activity = Activity.find(params[:id])
  end
  
  def update
    @activity = Activity.find(params[:id])
    @activity.update_attributes!(params[:activity])
    flash[:notice] = "修改成功"
    redirect_to activity_url(@activity.id)
  end
  
  def destroy
    @activity = Activity.find(params[:id])
    @activity.update_attributes!(:deleted_at => Time.now)
    flash[:notice] = "删除成功"
    redirect_to root_url
  end
  
  def join
    @activity = Activity.find(params[:id])
    if @activity.joined?(current_user)
      flash[:notice] = "你已经参加这个活动了, 不用重复点击"
    else
      @activity.participators << current_user
    end
    #logger.info "REQUEST URI: #{request.request_uri}"
    redirect_to activity_url(@activity)
  end
  
  def quit
    @activity = Activity.find(params[:id])
    if @activity.joined?(current_user)
      @activity.participators.delete current_user
    else
      flash[:notice] = "你没有参加过这个活动"
    end
    redirect_to activity_url(@activity)
  end

  def show
    begin
      @activity = Activity.find(params[:id])
      
      unless @activity.deleted_at.nil?
        flash[:notice] = "该活动已删除"
        redirect_to activities_url
      end
      
      @shares = @activity.shares
      @comments = @activity.comments.available.paginate :page => params[:page] || 1, :per_page => 15
      @comment = ActivityComment.new
    
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "没有找到这个活动, 可能已被管理员删除"
      redirect_to root_url
    end
    
  end
  
  def stick
    @activity = Activity.find(params[:id])
    @activity.toggle!(:sticky)
    flash[:notice] = "本活动已经置顶" if @activity.sticky?
    flash[:notice] = "本活动已经取消置顶" unless @activity.sticky?
    redirect_to activity_url(@activity)
  end
  
  
  private
  def find_activities(status)
    @activities = Activity.send(status.to_sym).available.paginate(:page => params[:page] || 1,
                                                                  :order => "created_at desc, start_at desc",
                                                                  :per_page => 20)
  end
  
end