# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "欢迎 #{current_user.login}, 你已经登录"
            
      redirect_back_or_default CGI.unescape(params[:to] || '/')
      
    else
      flash[:notice] = "邮件地址或密码错误"
      render :action => 'new'
    end
  end
  
  def reset_password
    @user = User.find_by_email(params[:email])
    
    respond_to do |format|
      if @user && @user.login == params[:login]
        flash[:notice] = "密码重置成功，新密码已发至您的信箱"
        @user.reset_password!
        format.html { redirect_to login_path}
      else
        flash[:notice] = "对不起，没有找到与您的输入相匹配的用户"
        format.html { render 'forget_password' }
      end
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
