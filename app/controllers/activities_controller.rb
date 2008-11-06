class ActivitiesController < ApplicationController
  before_filter :login_required, :except => [:index]
  
  def index
    
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    
    @activity.save!
    flash[:notice] = "发布成功"
    redirect_to activities_url
  end
  
  def geo_choice
    if !params[:departure_root_id].blank?
      @root = Geo.find(params[:departure_root_id])
      if @root.children.size > 0
        @geos = @root.children
      else
        @geos = [ @root ]
      end
      render :partial => "geo_selector", :locals => {:dom_id => "departure_id"}
      
    elsif !params[:arrival_root_id].blank?
      @root = Geo.find(params[:arrival_root_id])
      if @root.children.size > 0
        @geos = @root.children
      else
        @geos = [ @root ]
      end
      render :partial => "geo_selector", :locals => {:dom_id => "arrival_id"}
    end
  end
  
end