class Minisite::Lightenschool::DashboardController < ApplicationController
  
  before_filter :login_required, :only => [:submit, :processing]
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
    
    @guides = SchoolGuide.find_tagged_with('点亮学校').reverse.paginate(:per_page => 10, :page => params[:guide_page])
    @shares = Share.find_tagged_with('点亮学校').reverse.paginate(:per_page => 10, :page => params[:guide_page])
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