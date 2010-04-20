# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem

  # render new.rhtml
  def new
  end
  
  def ajax_login
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def create
    self.current_user = User.authenticate(params[:email], params[:password])

    respond_to do |format|
      if logged_in?
        if params[:remember_me] == "1"
          current_user.remember_me unless current_user.remember_token?
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        current_user.update_attribute(:ip, request.remote_ip)
        # 保存用户ID
        cookies[:onekg_id] = { :value => self.current_user.id , :expires => 1.year.from_now }
        flash[:notice] = "欢迎 #{current_user.login}, 你已经登录"
        format.html {redirect_back_or_default CGI.unescape(params[:to] || '/')}
        format.js {
          render :update do |page|
            page << 'parent.location.reload();'
          end
        }
      else
        flash[:notice] = "邮件地址或密码错误"
        format.html {render :action => 'new'}
        format.js do 
          render :update do |page|
            page << "alert('对不起，用户名或密码错误，请重新输入!');"
          end
        end
      end
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
    flash[:notice] = "已经退出，欢迎再来！"
    redirect_back_or_default('/')
  end
end
