# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  def message_notification(message_copy)
    @recipients = message_copy.recipient.email
    @from       = "多背一公斤 <no-reply@1kg.org>"
    @subject    = "[1KG]收到新的站内信"
    @sent_on    = Time.now
    @body       = {:message => message_copy.message,
                    :user => message_copy.recipient }
    @content_type = "text/html"
  end
  
  def new_password_notification(user, new_password)
    @recipients = user.email
    @from       = "多背一公斤 <no-reply@1kg.org>"
    @subject    = "[1KG]您的新帐户密码"
    @sent_on    = Time.now
    @body       = {:new_password => new_password}
  end
  
  def submitted_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? "newschools@googlegroups.com" : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "多背一公斤 <no-reply@1kg.org>"
    @subject     = "[1KG]用户提交了一所新学校，请审核"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def destroyed_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? school.user.email : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "多背一公斤 <no-reply@1kg.org>"
    @subject     = "[1KG]对不起，您提交的#{school.title}已被管理员删除"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def invalid_school_notification(school)
    @recipients  = ENV["RAILS_ENV"] == "production" ? school.user.email : "suave.su@gmail.com,zhangyuanyi@gmail.com"
    @from        = "多背一公斤 <no-reply@1kg.org>"
    @subject     = "[1KG]对不起，您提交的#{school.title}没有通过审核，请您对学校信息进行补充"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
  
  def create_default_user_for_mooncake(user, password)
    @recipients = ENV["RAILS_ENV"] == "production" ? user.email : "suave.su@gmail.com"
    @from       = "多背一公斤 <no-reply@1kg.org>"
    @subject    = "[1KG]欢迎加入1KG.org，请查看您的用户信息"
    @sent_on    = Time.now
    @body       = {:user => user, :password => password}
  end
  
  def donation(buyer_name, buyer_email, donation_url)
    @recipients = buyer_email
    @from = "no-reply@1kg.org"
    @subject = "谢谢购买公益产品，请阅读本邮件提示完成捐赠"
    @sent_on = Time.now
    @body = {:buyer_name => buyer_name, :donation_url => donation_url}
  end

end
