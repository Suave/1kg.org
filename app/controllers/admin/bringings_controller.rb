class Admin::BringingsController < Admin::BaseController
  
  def index 
    @executions = Execution.with_box.paginate(:page => 1, :per_page => 20)
    respond_to do |format|
      format.html {}
      format.csv {
      @boxes = Box.available
      if params[:from_at]
        @executions = Execution.with_box.find(:all,:conditions => ['created_at > (?)',params[:from_at].to_time])
      else
        @executions = Execution.with_box
      end
      }
    end
  end
  
  def validate
    @execution = Execution.find(params[:id])
    @execution.update_attributes(:validated_at => Time.now, :validated_by_id => current_user.id)
    @execution.allow
    @school = @execution.school
    flash[:notice] = "该项目已通过申请"
    message = Message.new(:subject => "你为#{@school.title}申请的一公斤盒子已经通过了审核",
                            :content => "<p>你好，#{@execution.user.login}:</p><br/><p>你为#{@school.title}申请的一公斤盒子已经通过了项目管里员的审核。</p>\
                                         <br/><p>之后该项目的管理者会联系你，确认如何向你提供一公斤盒子和使用帮助：</p>\
                                         <br/><p>而作为项目申请人你需要做到：</p>\
                                         <p> - 在获得支持后，按照你的执行计划按时完成项目的执行。</p>\
                                         <p> - 按照你的反馈计划，按时填写项目反馈，报告项目的进展。</p>\
                                         <br/><p>现在就去你的一公斤盒子页面看看吧。 => http://www.1kg.org/boxes/executions/#{@execution.id} </p>\
                                         <br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@execution.user]
    message.save!
    redirect_to admin_bringings_path
  end

  def refuse
    @execution = Execution.find(params[:id])
    @school = @execution.school
    @execution.refuse
    @execution.update_attributes(:refused_at => nil, :refused_by_id => current_user.id)
     message = Message.new(:subject => "你为#{@school.title}申请的一公斤盒子没有通过审核",
                            :content => "<p>你好，#{@execution.user.login}:</p><br/><p>你为#{@school.title}申请的一公斤盒子已经没有通过项目管里员的审核。</p>\
                                         <br/><p>有可能是因为你填写的内容不和要求或者有错误</p>\
                                         <br/><p>如果有更多疑问，请给这个邮箱发送邮件 contact@1kg.org </p>\
                                         <br/><p>我们会尽快给你回复。</p>\
                                         <br/><p>多背一公斤团队</p>"
                            )
    message.author_id = 0
    message.to = [@execution.user]
    message.save!
    flash[:notice] = "已拒绝申请"
    redirect_to admin_bringings_url
  end
  
end
