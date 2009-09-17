class Minisite::Lightenschool::DashboardController < ApplicationController
  include Minisite::Lightenschool::DashboardHelper
  
  before_filter :login_required, :only => [:submit, :process]
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
  end
  
  # 提交攻略和 user profile
  def submit
    @guide = SchoolGuide.new
    @profile = current_user.profile || Profile.new
  end

  def processing
    
  end
=begin    
  def register
    
  end
  
  
  # 保存报名表
  def apply
    unless user_profile_fullfill?(current_user.profile)
      @profile = current_user.profile || Profile.new
      render :action => "register" 
    else
      if current_user.profile
        current_user.profile.update_attributes!(params[:profile])
      else
        # 用户第一次填个人资料
        profile = Profile.new(params[:profile])
        current_user.profile = profile
        current_user.save!
      end
      
      flash[:notice] = "个人资料修改成功"
      redirect_to minisite_lightenschool_index_url
    end
    
    
  end
=end 
  
  def submit
    
  end
  
end