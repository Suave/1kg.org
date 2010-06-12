class CoDonationsController < ApplicationController
  before_filter :set_co_donation, :except => [:new, :create, :index]
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :need_permission ,:only => [:edit,:destory,:update,:admin_state]
  before_filter :get_state, :only => [:show]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:feedback]
  
  def index
    @co_donations = CoDonation.all(:limit => 10)
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
        wants.html {redirect_to school_url(@co_donation.school)}
      else
        wants.html {render 'new'}
      end
    end
  end
  
  def show
    @sub_donation = SubDonation.new
    @comments = @co_donation.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
  end
  
  def edit
    @schools = current_user.envoy_schools
  end
  
  def feedback
  end
  
  def update
    @co_donation = current_user.co_donations.find(params[:id])
    @schools = current_user.envoy_schools
    respond_to do |wants|
      if @co_donation.update_attributes(params[:co_donation])
        wants.html {redirect_to co_donation_url(@co_donation)}
      else
        wants.html {render 'edit'}
      end
    end  
  end
  
  def admin_state
    begin
      eval('')
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
    @co_donation = CoDonation.find(params[:id])
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
      @exist_donation = @co_donation.sub_donations.find(:last,:conditions => {:user_id => current_user.id})
      @state = (@exist_donation.nil?? nil : @exist_donation.state)
    else
      @state = nil
    end
  end
end