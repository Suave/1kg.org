class Minisite::Xmascard09::DashboardController < ApplicationController
  def index
    @group = Group.find_by_slug('xmascard09')
    @board = @group.discussion.board
  end
  
end