class BoxesController < ApplicationController
 
  before_filter :login_required, :only => [:create,:update,:new,:edit,:apply]

  def index
    @boxes = Box.available
    @executions = Execution.validated_with_box
    @my_executions  = current_user.executions.with_box if logged_in?
    @topics = Topic.find(:all,:conditions => {:boardable_type => 'Execution',:boardable_id => Execution.validated_with_box.map(&:id)},:order => 'created_at desc',:limit =>4)
    @photos = Photo.find(:all,:conditions => {:photoable_type => 'Execution',:photoable_id => Execution.validated_with_box.map(&:id)},:order => 'created_at desc',:limit =>4)
    @group = Group.find(:first,:conditions=>{:slug => 'box-design'})
  end

  def apply
    @execution = Execution.new
    @boxes = Box.available
    @bringings = @execution.bringings.build
    @schools = (current_user.followed_schools + current_user.managed('School') + current_user.visited_schools).uniq
  end

  def submit
    @execution = Execution.new(params[:execution])
    @execution.start_at = @execution.end_at = Date.new(params[:execution][:year].to_i,params[:execution][:month].to_i,1)
    params[:bringings].each do |bringing|
      @execution.bringings.build(bringing.merge({:user_id => current_user.id})) unless bringing[:number].to_i == 0
    end
    if @execution.bringings.size == 0
      @boxes = Box.available
      @bringings = @execution.bringings.build
      @schools = (current_user.followed_schools + current_user.managed('School') + current_user.visited_schools).uniq
      render "apply"
    elsif @execution.save
      flash[:notice] = "你的申请已经提交成功，请等候并持续关注，结果我们会通过站内信告知 :)"
      redirect_to boxes_path
    else
      @boxes = Box.available
      @bringings = @execution.bringings.build
      @schools = (current_user.followed_schools + current_user.managed('School') + current_user.visited_schools).uniq
      render "apply"
    end
  end

  def feedback
    @executions = Execution.validated_with_box.paginate :page => params[:page] || 1, :per_page => 10
    @feedback_type = {'photo'=> 'photo','topic' => 'topic'}[params[:feedback_type]]
  end

  def topics
    @executions = Execution.validated_with_box
    @topics = @executions.map(&:topics).flatten.paginate :page => params[:page] || 1, :per_page => 20
  end

  def photos
    @executions = Execution.validated_with_box
    @photos = @executions.map(&:photos).flatten.paginate :page => params[:page] || 1, :per_page => 20
  end

  def execution
    @execution = Execution.find(params[:id])
    @photos = @execution.photos
    @topics = @execution.topics
    @comments = @execution.comments.paginate :page => params[:page] || 1, :per_page => 20
    @comment = Comment.new
    render 'execution'
  end

  def executions
    @executions = Execution.validated_with_box.paginate :page => params[:page] || 1, :per_page => 20
  end

  def show
    @box = Box.find(params[:id])
    @boxes = Box.available - [@box]
    @comment = Comment.new
    @comments = @box.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
  end
end
