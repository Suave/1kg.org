class MiscController < ApplicationController
  def index
    @page_title = "首页"
    @activity_count = Activity.ongoing.size
    @hot_activities = Activity.ongoing.find(:all,:limit => 4,:order => "participations_count desc" ,:conditions => ["main_photo_id is not null and created_at > ?",1.months.ago])
    @voteds = Vote.find(:all,:order => "created_at desc",:limit => 40).map(&:voteable).uniq[0..10]
    @co_donations = CoDonation.validated.ongoing.all(:limit => 2)
    @teams = Team.validated.find(:all,:order => "created_at desc",:limit => 6)
    @bulletins = Bulletin.recent
    @visits = Visited.latestvisit
    @wannas = Visited.latestwanna
    @projects = Project.find(:all,:limit => 2,:order => "created_at desc",:conditions => ['id != ?',10]) #hack for operation
  end
    
  def show_page
    #for static page
    @page = Page.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
  end

end
