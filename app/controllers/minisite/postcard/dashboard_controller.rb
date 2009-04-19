require 'uuid'

class Minisite::Postcard::DashboardController < ApplicationController
  def index
    
  end
  
  def code_test
    1000.times do
      logger.info UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
    end
    render :action => "index"
  end
  
end