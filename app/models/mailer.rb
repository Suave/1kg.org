class Mailer < ActionMailer::Base

  def message_notification(message)
    @recipients  = message.receiver.email
    @from        = "no-reply@1kg.cn"
    @subject     = message.title
    @sent_on     = Time.now
    @body        = {:message => message}
  end
  
  def submitted_school_notification(school)
    @recipients  = "newschools@googlegroups.com"
    @from        = "no-reply@1kg.cn"
    @subject     = "有新提交的学校等待验证"
    @sent_on     = Time.now
    @body        = {:school => school}
  end
end
