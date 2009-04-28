require 'uuid'

class Minisite::Postcard::DashboardController < ApplicationController
  def index
    @board = PublicBoard.find_by_slug("postcard").board
    @topics = @board.topics.find(:all, :order => "sticky desc, last_replied_at desc", :limit => 10)
  end
  
  def password
    if params[:password].blank?
      flash[:notice] = "请输入贺卡上的爱心密码, 点击验证按钮"
    end
  end
  
=begin  
  def code_test
    1000.times do
      logger.info UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
    end
    render :action => "index"
  end
=end  
end