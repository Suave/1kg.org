# -*- encoding : utf-8 -*-
class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.find(:all,:order => "created_at desc")
  end
  
  def validate
    @team = Team.find params[:id]
    @team.update_attributes!(:validated => true,:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    
    message = Message.new(:subject => "你的团队页面通过了审核",
                            :content => "<p>你好，#{@team.user.login}:</p><br/><p>你为“#{@team.name}”申请的团队页面通过了审核。<br/>作为申请人，你是第一个团队管理员。<br/> 你可以在你的团队页面以团队的名义发起活动，也可以批准其他人成为活动管理员。</p><p>现在就去看看吧。 <br/>地址=> http://www.1kg.org/teams/#{@team.id} </p><br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@team.user]
    message.save!
    redirect_to admin_teams_path()
  end

  def cancel
    @team = Team.find params[:id]
    @team.update_attributes!(:validated => false,:validated_at => nil, :validated_by_id => current_user.id)
    flash[:notice] = "已取消验证"
    redirect_to admin_teams_path()
  end
  
end
