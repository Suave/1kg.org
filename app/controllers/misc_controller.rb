class MiscController < ApplicationController
  
  def index
    @page_title = "首页"
    @school_count = School.validated.size
    @activity_count = Activity.ongoing.size
    if logged_in? 
      public_look 
    else
      respond_to do |wants|
        wants.html{ render(:action => "welcome")}
      end
    end
  end
  
  def public_look
    @page_title = "首页"
    @school_count = School.validated.size
    @activity_count = Activity.ongoing.size
    @new_schools = School.find(:all,:limit => 4,:order => "created_at desc")
    @hot_activities = Activity.ongoing.find(:all,:limit => 4,:order => "participations_count desc" ,:conditions => {:created_at => 1.month.ago..Time.now})
    @voteds = Vote.find(:all,:order => "created_at desc",:limit => 50).map(&:voteable).uniq[0..10]
    @co_donations = CoDonation.validated.ongoing.all(:limit => 2)
    @teams = Team.validated.find(:all,:order => "created_at desc",:limit => 6)
    @bulletins = Bulletin.recent
    @visits = Visited.latestvisit
    @wannas = Visited.latestwanna
    @atom_shares = Share.find(:all,:limit => 10,:order => "created_at desc")
    
    respond_to do |wants|
      wants.html{render :action => "index"}
      wants.atom{render :action => "index"}
    end
  end
    
  def show_page
    #for static page
    @page = Page.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
  end

end
