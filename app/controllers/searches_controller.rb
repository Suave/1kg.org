class SearchesController < ApplicationController
  def show
    @search = Search.new(params)

    search_school if @search.kind == 'school'
    search_activity if @search.kind == 'activity'
    search_share if @search.kind == 'share'
        
    respond_to do |format|
      format.html
    end
  end
  
  private
  def search_activity
    @activities = @search.activities(params[:page], 14)
  end
  
  def search_share
    @shares = @search.shares(params[:page])
  end
  
  def search_school
    @map_center = Geo::DEFAULT_CENTER
    @schools = @search.schools(params[:page]) 
    
    @json = []
    @schools.each do |school|
      next if school.basic.blank?
      @json << {:i => school.id,
                       :t => school.icon_type,
                       :n => school.title,
                       :a => school.basic.latitude,
                       :o => school.basic.longitude
                       }
    end
  end
end
