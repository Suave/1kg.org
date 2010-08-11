class Admin::ProjectsController < Admin::BaseController
  def index
    @projects = Project.find :all, :order => "id desc"
  end
 
  def validate
    @project = Project.find params[:id]
    @project.validate
    @project.update_attributes(:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    
    message = Message.new(:subject => "你发起的团捐通过了审核",
                            :content => "<p>你好，#{@project.user.login}:</p><br/><p>你发起的团捐“#{@project.title}”通过了审核，已经可以接受大家的捐赠了。</p><br/><p>作为发起人你需要做到：</p><p> - 及时确认他人的捐赠。</p><p> - 按照你的反馈计划的承诺来执行反馈。</p><br/><p>现在就去你的团捐页面看看吧，还可以使用邀请功能提示你的好友们。 => http://www.1kg.org/projects/#{@project.id} </p><br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@project.user]
    message.save!
  
    redirect_to admin_projects_path()
  end

  def refuse
    @project = Project.find params[:id]
    @project.refuse
    @project.update_attributes(:refused_at => nil, :refused_by_id => current_user.id)
    flash[:notice] = "已拒绝申请"
    redirect_to admin_projects_path()
  end
  
end