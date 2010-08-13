class Admin::ProjectsController < Admin::BaseController
  def index
    @projects = Project.find :all, :order => "id desc"
  end
 
  def validate
    @project = Project.find params[:id]
    @project.allow
    @project.update_attributes(:validated_at => Time.now, :validated_by_id => current_user.id)
    flash[:notice] = "已通过验证"
    #项目申请成功的站内信
    message = Message.new(:subject => "你发起的公益项目已经通过了审核",
                          :content => "<p>你好，#{@project.user.login}:</p><br/><p>你发起的公益项目“#{@project.title}”通过了审核，已经可以接受大家的申请了。</p>\
                                       <br/><p>作为发起人你需要做到：</p>\
                                       <p> - 及时通过或拒绝申请人的项目申请</p>\
                                       <p> - 按照你项目说明的承诺对通过的申请者或学校给予支持</p>\
                                       <p> - 在申请者完成项目执行后，对他的执行情况给予评价。</p>\
                                       <br/><p>现在就去你的项目页面看看吧。 => http://www.1kg.org/projects/#{@project.id} </p>\
                                       <br/><p>多背一公斤团队</p>"
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
    redirect_to refuse_letter_admin_project_path(@project)
  end
  
  def refuse_letter
    @project = Project.find params[:id]
    flash[:notice] = "拒绝了公益项目“#{@project.title}”的通过，这是发给项目发起人的站内信，你可以修改此站内信的内容，说明申请被拒绝的原因。"
    @message = Message.new
    @recipient = @project.user
  end
  
end