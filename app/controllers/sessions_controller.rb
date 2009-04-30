# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem

  # render new.rhtml
  def new
    #logger.info "REQUEST URI: #{session[:return_to]}"
    # for adwords tracker
    if session[:return_to] =~ /^\/activities\/[0-9]+\/join$/
      session[:from_activity_join] = false
    end
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "欢迎 #{current_user.login}, 你已经登录"
      
      # for adwords tracker
      session[:from_activity_join] = true if session[:from_activity_join] == false
      
      redirect_back_or_default('/')
      
    else
      flash[:notice] = "邮件地址或密码错误"
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "已经注销，欢迎再来！"
    redirect_back_or_default('/')
  end
end
