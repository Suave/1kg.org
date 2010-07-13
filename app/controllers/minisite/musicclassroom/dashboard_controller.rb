class Minisite::Musicclassroom::DashboardController < ApplicationController
  
  def index
    @project = RequirementType.last
    @photos = Photo.with_school.find(:all,:limit => 8,:order => "created_at desc", :group => "school_id")
    @shares = Share.find(:all,:limit => 5)
  end
  
end