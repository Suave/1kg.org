class SubDonationsController < ApplicationController
  before_filter :login_required
  before_filter :set_co_donation
  
  def create
    @sub_donation = @co_donation.sub_donations.build(params[:sub_donation])
    @sub_donation.user_id = current_user.id
    
    respond_to do |wants|
      if @sub_donation.save
        wants.html { redirect_to edit_co_donation_sub_donation_path(@co_donation, @sub_donation)}
      else
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def show
  end
  
  def edit
    @sub_donation = @co_donation.sub_donations.find(params[:id])
  end
  
  def verify
  end
  
  def update
    @sub_donation = @co_donation.sub_donations.find(params[:id])
    
    respond_to do |wants|
      if @sub_donation.update_attributes(params[:sub_donation])
        wants.html { redirect_to @co_donation}
      else
        wants.html {render 'edit'}
      end
    end
  end
  
  private
  def set_co_donation
    @co_donation = CoDonation.find(params[:co_donation_id])
  end
end