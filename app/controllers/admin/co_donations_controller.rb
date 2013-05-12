# -*- encoding : utf-8 -*-
class Admin::CoDonationsController < Admin::BaseController
  def index
    @co_donations = CoDonation.find(:all,:order => "created_at desc")
  end
  
  def validate
    @co_donation = CoDonation.find params[:id]
    @co_donation.update_attributes!(:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    
    message = Message.new(:subject => "你发起的团捐通过了审核",
                            :content => "<p>你好，#{@co_donation.user.login}:</p><br/><p>你发起的团捐“#{@co_donation.title}”通过了审核，已经可以接受大家的捐赠了。</p><br/><p>作为发起人你需要做到：</p><p> - 及时确认他人的捐赠。</p><p> - 按照你的反馈计划的承诺来执行反馈。</p><br/><p>现在就去你的团捐页面看看吧，还可以使用邀请功能提示你的好友们。 => http://www.1kg.org/co_donations/#{@co_donation.id} </p><br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@co_donation.user]
    message.save!
    redirect_to admin_co_donations_path()
  end

  def cancel
    @co_donation = CoDonation.find params[:id]
    @co_donation.update_attributes!(:validated => false,:validated_at => nil, :validated_by_id => current_user.id)
    flash[:notice] = "已取消验证"
    redirect_to admin_co_donations_path()
  end
  
end
