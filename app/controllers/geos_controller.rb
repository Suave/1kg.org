class GeosController < ApplicationController
  
  # for multiple drop down select
  def geo_choice
    if !params[:root].blank?
      @root = Geo.find(params[:root])
      if @root.children.size > 0
        @geos = @root.children
      else
        @geos = [ @root ]
      end
      render :partial => "geo_selector", :locals => { :object => params[:object], :method => params[:method] }
    end
  end
  
  def county_choice
    if !params[:geo].blank?
      @geo = Geo.find(params[:geo])
      if @geo.counties.size > 0
        @counties = @geo.counties
      else
        @counties = []
      end
      render :partial => "geo_selector", :locals => { :object => "school", :method => "county" }
    end
  end
end