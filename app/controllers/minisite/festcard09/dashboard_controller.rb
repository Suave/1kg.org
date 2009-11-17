class Minisite::Festcard09::DashboardController < ApplicationController
  def index
    @group = Group.find_by_slug('postcard')
    @board = @group.discussion.board
  end
  
end