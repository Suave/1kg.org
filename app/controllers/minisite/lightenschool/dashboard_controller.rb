class Minisite::Lightenschool::DashboardController < ApplicationController
  
  before_filter :login_required, :only => [:submit, :processing]
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
    #怎么对一个arrey以每个元素的updated_at属性来排序呢？
    @guides = Share.find_tagged_with('点亮学校',:order => "updated_at desc").paginate(:per_page => 20, :page => params[:guide_page])
    
  end
  
  def submit
    @school_guide = SchoolGuide.new
    @profile = current_user.profile || Profile.new
  end

  def processing
    @school_guide = SchoolGuide.new params[:school_guide]
    @school_guide.tag_list.add '点亮学校'
    @school_guide.user = current_user
     
    profile = { :first_name => params[:first_name],
                :last_name  => params[:last_name],
                :phone      => params[:telephone] }
    
    unless update_user_profile(profile)
      flash[:notice] = "请您完成填写个人资料，方便主办方与您联系"
      render :action => "submit"
    else
      if @school_guide.save
        flash[:notice] = "攻略提交成功！"
        redirect_to minisite_lightenschool_index_url
      else
        #logger.info @school_guide.errors.full_messages.join("\n") 
        render :action => "submit"
      end
    end
  end
  
  def winners
    gold = [1000739,1000753,1000766]
    silver = [1000502,1000760, 1000737, 1000743, 1000740, 1000758, 1000736, 1000764, 1000738, 1000767, 1000751, 1000742, 1000749, 1000757, 1000761, 1000741, 1000752, 1000420, 1000755, 1000447, 1000532, 1000748, 1000750, 1000462, 46, 73, 130, 147, 133, 1000759]
    cooper = [1000454,1000534,1000763,1000580,1000608,134,163,7,133,1000487,1000756,1000746,2,88,44,1000318,1000375,1000328,224,1000535,1000555,1000594,69,1000338,1000595,250,164,1000358,1000373,125,1000592,1000426,1000561,1000505,1000434,1000590,1000501,45,1000471,1000547,1000582,1000374,1000335,31,10,9,1000450,12,1000326,128,120,66,67,79,1000308,1000606,110,296,4,136]
    @classone = gold.map {|id| Share.find(id) }
    @classtwo = silver.map {|id| Share.find(id) }
    @classthree = cooper.map {|id| Share.find(id) }
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