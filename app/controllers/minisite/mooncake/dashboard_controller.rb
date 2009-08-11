require 'uuid'

class Minisite::Mooncake::DashboardController < ApplicationController
  before_filter :login_required, :except => [:index, :reserve]
  
  def index
    @reserve = Reserve.new
  end
  
  def reserve
    @reserve = Reserve.new params[:reserve]
    @reserve.save!
    #flash[:notice] = "已经收到您的预定，面市后我们会及时通知您"
    #redirect_to minisite_mooncake_index_url
  end
  
end