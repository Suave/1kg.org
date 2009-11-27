class Minisite::Festcard09::DashboardController < ApplicationController
  def index
    @group = Group.find_by_slug('postcard')
    @board = @group.discussion.board
    
    postcard = StuffType.find_by_slug("festcard09")
    @for_team_bucks   = postcard.bucks.for_team_donations.find :all, :include => [:school]
    
  end
  
  def cards
    
  end
  
end