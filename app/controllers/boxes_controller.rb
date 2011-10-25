class BoxesController < ApplicationController
 
  before_filter :login_required, :only => [:create,:update,:new,:edit,:apply]

  def index
    @boxes = Box.available
    @executions = Execution.validated_with_box
    @my_executions  = current_user.executions.with_box if logged_in?
    @shares = @executions.map(&:shares).flatten[0..7]
    @photos = @executions.map(&:photos).flatten[0..7]
    @executions = @executions[0..7]
  end

  def apply
    @execution = Execution.new
    @boxes = Box.available
    @bringings = @execution.bringings.build
    @schools = (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
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
      @schools = (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
      render "apply"
    elsif @execution.save
      flash[:notice] = "你的申请已经提交成功，请等候并持续关注，结果我们会通过站内信告知 :)"
      redirect_to boxes_path
    else
      @boxes = Box.available
      @bringings = @execution.bringings.build
      @schools = (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
      render "apply"
    end
  end

  def new_photo
    @executions = Execution.validated_with_box
  end

  def new_share
    @executions = Execution.validated_with_box
  end

  def execution
    @execution = Execution.find(params[:id])
    @photos = @execution.photos
    @shares = @execution.shares
    @comments = @execution.comments.paginate :page => params[:page] || 1, :per_page => 20
    render 'execution'
  end

  def executions
    @executions = Execution.validated_with_box.paginate :page => params[:page] || 1, :per_page => 20
  end

  def show
    @box = Box.find(params[:id])
    @boxes = Box.available - [@box]
    @comments = @box.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 20
  end
