require 'uuid'

class Minisite::Mooncake::DashboardController < ApplicationController
  before_filter :login_required, :except => [:index]
  
  def index
    
  end
  
end