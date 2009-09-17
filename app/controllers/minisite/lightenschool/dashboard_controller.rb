class Minisite::Lightenschool::DashboardController < ApplicationController
  
  def index
    @group = Group.find_by_slug('lightenschool')
    @board = @group.discussion.board
    
  end
  
  def submit
    
  end
  
end