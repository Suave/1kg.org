class Minisite::Lightenschool::DashboardController < ApplicationController
  
  before_filter :login_required, :only => [:submit, :processing]
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
    #怎么对一个arrey以每个元素的updated_at属性来排序呢？
    @guides = Share.find_tagged_with('点亮学校',:order => "updated_at desc").paginate(:per_page => 20, :page => params[:guide_page])
    
  end
  
  def winners
    gold = [1000758,1000769,1000781]
    silver = [1000756,1000775,1000759,1000757,1000753,1000754,1000752,1000774,1000779,1000502,1000782,1000761,1000781,1000766,1000776,1000773,1000755,1000760,1000420,1000771,1000447,1000765,1000751,1000767,1000532,130,46,73,147,1000462]
    cooper = [1000534,1000454,1000580,1000778,1000608,1000450,1000772,1000606,125,44,1000358,1000763,120,2,12,1000594,4,1000583,1000318,9,1000501,1000328,1000535,1000374,31,134,7,45,1000555,1000335,1000434,296,1000338,1000547,1000592,164,67,69,10,66,1000326,250,1000426,1000375,1000308,79,224,110,1000373,1000590,136,128,88,1000582,1000487,163,1000595,1000505,133,1000471,1000561]
    @classone = Share.find(:all,:conditions => ["id in (?)",gold])
    @classtwo = Share.find(:all,:conditions => ["id in (?)",silver])
    @classthree = Share.find(:all,:conditions => ["id in (?)",cooper])
  end
  
  def required
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