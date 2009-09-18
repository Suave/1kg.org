class Minisite::Lightenschool::DashboardController < ApplicationController
  include Minisite::Lightenschool::DashboardHelper
  
  before_filter :login_required, :only => [:submit, :processing]
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
  end
  
  def submit
    @school_guide = SchoolGuide.new
    @profile = current_user.profile || Profile.new
  end

  def processing
    profile = { :first_name => params[:first_name],
                :last_name  => params[:last_name],
                :phone      => params[:phone] }
                
    if current_user.profile
      current_user.profile.update_attributes!(profile)
    else
      # 用户第一次填个人资料
      profile = Profile.new(profile)
      current_user.profile = profile
      current_user.save!
    end
  end
  
end