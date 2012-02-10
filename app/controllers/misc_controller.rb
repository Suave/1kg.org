class MiscController < ApplicationController
  def index
    @page_title = "首页"
    @activity_count = Activity.ongoing.size
    @activities = Activity.hot
    @co_donations = CoDonation.validated.ongoing.all(:limit => 2)
    @bulletins = Bulletin.recent
  end
    
  def show_page
    #for static page
    @page = Page.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
  end

end
