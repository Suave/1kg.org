require 'uuid'

class Minisite::Postcard::DashboardController < ApplicationController
  def index
    @board = PublicBoard.find_by_slug("postcard").board
    @topics = @board.topics.find(:all, :order => "last_replied_at desc", :limit => 10)
  end
  
  def code_test
    1000.times do
      logger.info UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
    end
    render :action => "index"
  end
  
end