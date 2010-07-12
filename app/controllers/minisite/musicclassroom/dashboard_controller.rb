class Minisite::Musicclassroom::DashboardController < ApplicationController
  
  def index
    @group = Group.find_by_slug('postcard')
    @board = @group.discussion.board
    @project = RequirementType.last
    @photos = Photo.with_school.find(:all,:limit => 8,:order => "created_at desc", :group => "school_id")
  end
  
end