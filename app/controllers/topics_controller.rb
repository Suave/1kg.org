class TopicsController < ApplicationController
  before_filter :login_required, :except => [:show, :index,:total]
  before_filter :find_topic,     :except => [:index,:new,:create,:total]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def total
    @topics = Topic.find(:all,:limit => 100,:order => "last_replied_at desc").paginate(:page => params[:page] || 1, :per_page => 10)
  end
  
  def new
    @topic = Topic.new(:boardable_id => params[:boardable_id],:boardable_type => params[:boardable_type])
  end
  
  def create
    @topic = Topic.new(params[:topic])
    @topic.user = current_user
    if @topic.save
      flash[:notice] = "发帖成功"
      redirect_to url_for(@topic.boardable)
    else
      flash[:notice] = "发帖成功"
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    @topic.update_attributes!(params[:topic].merge({:last_modified_at => Time.now,
                                                    :last_modified_by_id => current_user.id
                                                   }))
    flash[:notice] = "帖子修改成功"
    redirect_to board_topic_url(@board, @topic)
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "帖子删除成功"
    redirect_to board_url(@board)
  end
  
  def vote
    respond_to do |format|
      if @topic.nil?
        flash[:notice] = '对不起，帖子不存在'
        format.html {redirect_to root_path}
      elsif current_user.voted?(@topic)
        flash[:notice] = '对不起，您已经投过票了'
        format.html {redirect_to board_topic_path(@topic.board, @topic)}
      else
        vote = @topic.votes.build(:vote => true, :user_id => current_user.id)
        vote.save(false)
        flash[:notice] = '推荐成功'
        format.html {redirect_to board_topic_path(@topic.board, @topic)}
      end
    end
  end
  
  def show
    @comments = @topic.comments.paginate(:page => params[:page] || 1, :per_page => 15)
    @boardable = @topic.boardable
    @comment  = Comment.new
    @others  = @topic.boardable.topics.find(:all,:limit => 6,:order => "last_replied_at desc") - [@topic]
  end
  
  def stick
    @topic.toggle!(:sticky)
    flash[:notice] = "本帖已经置顶" if @topic.sticky?
    flash[:notice] = "本帖已经取消置顶" unless @topic.sticky?
    redirect_to board_topic_url(@board, @topic)
  end
  
  def close
    @topic.toggle!(:block)
    flash[:notice] = "本帖已经关闭回复" if @topic.block?
    flash[:notice] = "本帖可以回复" unless @topic.block?
    redirect_to board_topic_url(@board, @topic)
  end
  
  
  private
  def find_topic
    @topic = Topic.find(params[:id])
  end
  
  
end
