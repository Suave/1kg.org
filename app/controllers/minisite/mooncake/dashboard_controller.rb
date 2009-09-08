require 'uuid'

class Minisite::Mooncake::DashboardController < ApplicationController
  before_filter :login_required, :except => [:index, :reserve, :buy, :password]
  
  def index
    #@reserve = Reserve.new
    render :action => "new"
  end
  
  def reserve
    #@reserve = Reserve.new params[:reserve]
    #@reserve.save!
    #flash[:notice] = "已经收到您的预定，面市后我们会及时通知您"
    #redirect_to minisite_mooncake_index_url
  end
  
  def password
    flash[:notice] = "密码配对功能9月10日启用"
    redirect_to index_path
  end
  
  
  def buy
    
  end
  
  private
  def index_path
    minisite_mooncake_index_url
  end
  
end