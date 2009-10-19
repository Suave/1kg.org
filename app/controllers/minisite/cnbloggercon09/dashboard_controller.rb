class Minisite::Cnbloggercon09::DashboardController < ApplicationController
  def index
    @group = Group.find_by_slug('cnbloggercon09')
    @board = @group.discussion.board
  end
end