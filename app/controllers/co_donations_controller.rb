class CoDonationsController < ApplicationController
  before_filter :set_co_donation, :except => [:new, :create, :index]
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :need_permission ,:only => [:edit,:destory,:update,:admin_state]
  before_filter :get_state, :only => [:show]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:feedback]
  
  def index
    @co_donations = CoDonation.validated.ongoing.all(:limit => 10)
    @sub_donations = logged_in? ? current_user.sub_donations : nil
    @group = Group.find_by_slug('co_donation')
    @board = @group.discussion.board
    @recent = SubDonation.recent
  end
  
  def new
    @co_donation = CoDonation.new
    @co_donation.school_id = params[:school_id]
    @schools = current_user.envoy_schools
  end
  
  def create
    @co_donation = current_user.co_donations.build(params[:co_donation])
    @schools = current_user.envoy_schools
    
    respond_to do |wants|
      if @co_donation.save
        flash[:notice] = "你的团捐已经发出，我们会尽快审核你的申请，申请成功后会发送站内信通知你。"
        
        message = Message.new(:subject => "我们会尽快审核你发起的团捐",
                                :content => "<p>你好，#{@co_donation.user.login}:</p><br/><p>你发起的团捐“#{@co_donation.title}”已经提交了，为了保证团捐的有效，我们会对你的申请进行审核。<br/>通过审核后大家就可以开始捐赠了，同时会有站内信通知你。</p> <br/><p>多背一公斤团队</p>"
                                )
        message.author_id = 0
        message.to = [@co_donation.user]
        message.save!
        
        wants.html {redirect_to co_donations_url}
      else
        wants.html {render 'new'}
      end
    end
  end
  
  def show
    @sub_donation = SubDonation.new
    @photos = @co_donation.photos.find(:all,:limit => 5)
    @comments = @co_donation.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
  end
  
  def edit
    @schools = current_user.envoy_schools
  end
  
  def feedback
    @co_donation = current_user.co_donations.find(params[:id])
  end
   
  def update
    @co_donation = current_user.co_donations.find(params[:id])
    @schools = current_user.envoy_schools
    respond_to do |wants|
      if @co_donation.update_attributes(params[:co_donation])
        flash[:notice] = "捐赠数量修改成功"
        wants.html {redirect_to co_donation_url(@co_donation)}
      else
        wants.html {redirect_to co_donation_url(@co_donation)}
      end
    end  
  end
  
  def destroy
    @co_donation.destroy
    
    respond_to do |wants|
      wants.html {redirect_to school_url(@co_donation.school)}
    end  
  end
  
  private
  def set_co_donation
    @co_donation = CoDonation.validated.find(params[:id])
  end
  
  def need_permission
    if @co_donation.user == current_user
    elsif current_user.admin?
    else
      flash[:notice] = "你没有权限进行此操作"
      redirect_to co_donation_url(@co_donation)
    end
  end
  
  #检测用户的捐赠状态
  def get_state
    if logged_in?
      @exist_donation = @co_donation.sub_donations.find(:first,:conditions => {:user_id => current_user.id},:order => "created_at desc")
      @state = (@exist_donation.nil?? nil : @exist_donation.state)
    else
      @state = nil
    end
  end
end