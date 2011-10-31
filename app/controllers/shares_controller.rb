class SharesController < ApplicationController
  before_filter :login_required, :except => [:show, :index]
  before_filter :find_share, :except => [:create, :index]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @shares = Share.paginate :page => params[:page] || 1,
                                       :order => "last_replied_at desc",
                                       :per_page => 10
                                       
    @hot_users = User.find_by_sql("select users.id, users.login, users.avatar, count(user_id) as count from shares left join users on users.id=shares.user_id and users.deleted_at is null where shares.deleted_at is null group by user_id order by count desc limit 5;");
  end
  
  
  def new
    @school = School.find_by_id(params[:school_id])
    @activity = Activity.find_by_id(params[:activity_id])
    @execution = Execution.find_by_id(params[:execution_id])
    @school = @execution.school if @execution
    @school = @activity.school if @activity && @activity.school
    @geo = @school.geo unless @school.nil?
  end
  
  def create
      @share = Share.new(params[:share])
      @share.user = current_user
      @share.save!
      redirect_to share_url(@share)
  end
  
  def edit
  end
  
  def vote
    @share = Share.find(params[:id])
    
    respond_to do |format|
      if @share.nil?
        flash[:notice] = '对不起，攻略不存在'
        format.html {redirect_to root_path}
      elsif current_user.voted?(@share)
        flash[:notice] = '对不起，您已经投过票了'
        format.html {redirect_to share_path(@share)}
      else
        vote = @share.votes.build(:vote => true, :user_id => current_user.id)
        vote.save(false)
        flash[:notice] = '推荐成功'
        format.html {redirect_to share_path(@share)}
      end
    end
  end
  
  def update
    @share.update_attributes!(params[:share])
    flash[:notice] = "您刚刚的修改已保存"
    redirect_to share_url(@share)
  end
  
  def destroy
    @share.destroy
    flash[:notice] = "您刚删除了活动帖子<#{@share.title}>"
    redirect_to user_url(current_user)
  end
  
  
  def show
    @share.hit!
    @voters = @share.votes.map(&:user)
    @comments = @share.comments.available.paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
    
    respond_to do |wants|
      wants.html
    end
  end
  
  private
  def find_share
    @share = params[:id] ? Share.find(params[:id]) : Share.new
  end
end
