class Minisite::Lightenschool::DashboardController < ApplicationController
  
  def index
    @group = Group.find_by_slug('guide')
    @board = @group.discussion.board
    
  end
  
end