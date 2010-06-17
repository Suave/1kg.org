class Admin::CoDonationsController < Admin::BaseController
  def index
    @co_donations = CoDonation.not_validated + CoDonation.validated
  end
  
  def validate
    @co_donation = CoDonation.find params[:id]
    @co_donation.update_attributes!(:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    redirect_to admin_co_donations_path()
  end

  def cancel
    @co_donation = CoDonation.find params[:id]
    @co_donation.update_attributes!(:validated => true,:validated_at => nil, :validated_by_id => current_user.id)
    flash[:notice] = "已取消验证"
    redirect_to admin_co_donations_path()
  end
  
end