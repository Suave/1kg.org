class SubDonationsController < ApplicationController
  before_filter :login_required
  before_filter :set_co_donation
  
  def index
    @sub_donations = @co_donation.sub_donations.paginate(:per_page => 20, :page => params[:page], :order => "updated_at DESC")
    
    respond_to do |wants|
      if current_user.id == @co_donation.user_id
        wants.html
      else
        flash[:notice] = '对不起，您没有足够的权限查看此页面'
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def create
    @sub_donation = @co_donation.sub_donations.build(params[:sub_donation])
    @sub_donation.user_id = current_user.id
    
    respond_to do |wants|
      if @sub_donation.save
        flash[:notice] = "为保证捐赠的有效性，请在7日内上传此捐赠的相关证明图片"
        wants.html { redirect_to co_donation_path(@co_donation)}
      else
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def edit
    @sub_donation = @co_donation.sub_donations.find(params[:id])
  end
  
  def verify
    @sub_donation = @co_donation.sub_donations.find(params[:id])
    
    respond_to do |wants|
      if current_user.id == @co_donation.user_id
        flash[:notice] = '操作已成功'
        @sub_donation.update_attribute(:verified, true)
        wants.html {redirect_to co_donation_sub_donations_path(@co_donation)}
      else
        flash[:notice] = '对不起，您没有足够的权限查看此页面'
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def cancel
    @sub_donation = @co_donation.sub_donations.find(params[:id])    
    
    respond_to do |wants|
      if current_user.id == @co_donation.user_id
        flash[:notice] = '操作已成功'
        @sub_donation.update_attribute(:verified, false)        
        wants.html {redirect_to co_donation_sub_donations_path(@co_donation)}
      else
        flash[:notice] = '对不起，您没有足够的权限查看此页面'
        wants.html {redirect_to @co_donation}
      end
    end
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