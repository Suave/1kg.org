module Minisite::Lightenschool::DashboardHelper

  def user_profile_fullfill?(profile)
    return false if profile.nil? # user profile doesn't exist

    %w(last_name first_name phone).each do |attr|
      return false if profile.send(attr).blank?
    end

    return true
  end
end