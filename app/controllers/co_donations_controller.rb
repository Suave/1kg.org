class CoDonationsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  
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
    @activity = @co_donation = CoDonation.find(params[:id])
    @sub_donation = SubDonation.new
    @comments = @co_donation.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 15
    @comment = Comment.new
  end
  
  def edit
    @activity = @co_donation = current_user.co_donations.find(params[:id])
  end
  
  def feedback
    @activity = @co_donation = current_user.co_donations.find(params[:id])
  end
  
  def update
    @activity = @co_donation = current_user.co_donations.find(params[:id])
    
    respond_to do |wants|
      if @co_donation.update_attributes(params[:co_donation])
        wants.html {redirect_to co_donation_url(@co_donation)}
      else
        wants.html {render 'edit'}
      end
    end  
  end
  
  def destroy
    @activity = @co_donation = current_user.co_donations.find(params[:id])
    @co_donation.destroy
    
    respond_to do |wants|
      wants.html {redirect_to school_url(@co_donation.school)}
    end  
  end
end