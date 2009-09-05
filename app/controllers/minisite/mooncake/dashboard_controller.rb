#require 'uuid'

class Minisite::Mooncake::DashboardController < ApplicationController
  include StuffUtil
  before_filter :login_required, :except => [:index, :password]
  before_filter :find_stuff_type, :only => [:password]
  def index
    render :action => "new"
  end
  

  def password
    return set_message_and_redirect_to_index("请输入爱心密码, 点击提交按钮") if params[:password].blank?
    
    @stuff = @stuff_type.stuffs.find_by_code(params[:password])
    if @stuff.blank?
      return set_message_and_redirect_to_index("您的密码不正确")
    elsif @stuff.matched?
      return set_message_and_redirect_to_index("您的密码已配过对了")
    else
      #return set_message_and_redirect_to_index("太好了！还没配对")
      if logged_in?
        @stuff.school = @stuff.buck.school
        render :action => "write_comment"
      else
        # 提示登录或注册
      end
    end
=begin    
    flash[:notice] = "密码配对功能9月10日启用"
    redirect_to index_path
=end
  end
  
  def comment
    
  end
  
  
  private
  def index_path
    minisite_mooncake_index_url
  end
  
  def find_stuff_type
    @stuff_type = StuffType.find_by_slug("mooncake")
  end
  
end