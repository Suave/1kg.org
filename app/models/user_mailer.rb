class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += '激活你的多背一公斤(1KG.org)帐户'
    if ENV['RAILS_ENV'] == 'development'
      @body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
    else
      @body[:url]  = "http://dev.1kg.org/activate/#{user.activation_code}"
    end
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += '你的帐户已经激活，欢迎加入多背一公斤'
    @body[:url]  = "http://dev.1kg.org/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "no-reply@1kg.cn"
      @subject     = ""
      @sent_on     = Time.now
      @body[:user] = user
    end
end
