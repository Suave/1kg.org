class DonationActivitiesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  
  def index
    @donation_activities = DonationActivity.all(:limit => 10)
  end
  
  def new
    @donation_activity = DonationActivity.new
    @donation_activity.school_id = params[:school_id]
  end
  
  def create
    @donation_activity = current_user.donation_activities.build(params[:donation_activity])
    
    respond_to do |wants|
      if @donation_activity.save
        wants.html {redirect_to school_url(@donation_activity.school)}
      else
        wants.html {render 'new'}
      end
    end
  end
  
  def show
    @activity = @donation_activity = DonationActivity.find(params[:id])
  end
  
  def edit
    @activity = @donation_activity = current_user.donation_activities.find(params[:id])
  end
  
  def update
    @activity = @donation_activity = current_user.donation_activities.find(params[:id])
    
    respond_to do |wants|
      if @donation_activity.update_attributes(params[:donation_activity])
        wants.html {redirect_to donation_activity_url(@donation_activity)}
      else
        wants.html {render 'edit'}
      end
    end  
  end
  
  def destroy
    @activity = @donation_activity = current_user.donation_activities.find(params[:id])
    @donation_activity.destroy
    
    respond_to do |wants|
      wants.html {redirect_to school_url(@donation_activity.school)}
    end  
  end
end