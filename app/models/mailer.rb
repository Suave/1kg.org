class Mailer < ActionMailer::Base
  def new_password_notification(user, new_password)
    @recipients = user.email
    @from       = "no-reply@1kg.org"
    @subject    = "[多背一公斤]您的新帐户密码"
    @sent_on    = Time.now
    @body       = {:new_password => new_password}
  end
  
  def message_notification(message)
    @recipients  = message.receiver.email
    @from        = "no-reply@1kg.org"
    @subject     = message.title
    @sent_on     = Time.now
    @body        = {:message => message}
  end
  
  def submitted_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? "newschools@googlegroups.com" : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "no-reply@1kg.org"
    @subject     = "用户提交了一所新学校，请审核"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def destroyed_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? school.user.email : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "no-reply@1kg.org"
    @subject     = "对不起，您提交的#{school.title}已被管理员删除"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def invalid_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? school.user.email : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "no-reply@1kg.org"
    @subject     = "对不起，您提交的#{school.title}没有通过审核，请您对学校信息进行补充"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def create_default_user_for_mooncake(user, password)
    @recipients = ENV["RAILS_ENV"] == "production" ? user.email : "suave.su@gmail.com"
    @from       = "no-reply@1kg.org"
    @subject    = "欢迎加入1KG.org，请查看您的用户信息"
    @sent_on    = Time.now
    @body       = {:user => user, :password => password}
    
  end
  
end
