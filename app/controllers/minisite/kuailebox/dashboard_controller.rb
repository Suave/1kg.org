class Minisite::Kuailebox::DashboardController < ApplicationController
  
  def index
    @group = Group.find_by_slug('kuailebox')
  
    
  end
  
  private
  def update_user_profile(profile)
    @profile = current_user.profile || Profile.new
    
    profile.each_value do |v|
      return false if v.blank?
    end
    
    unless @profile.new_record?
      @profile.update_attributes!(profile)
    else
      # 用户第一次填个人资料
      current_user.profile = @profile
      current_user.save!
    end
    return true
  end
  
end