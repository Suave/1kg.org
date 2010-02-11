class SearchesController < ApplicationController
  def show
    @page = params[:page]
    @search = Search.new(params)

    search_school if @search.kind == 'school'
    search_activity if @search.kind == 'activity'
    search_share if @search.kind == 'share'
    search_group if @search.kind == 'group'
    search_topic if @search.kind == 'topic'
    
    if @search.kind == 'all'
      @records = @search.records(@page)
      @objects = @records.group_by {|r| r.class.to_s}
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  private
  def search_activity
    @activities = @search.activities(@page, 14)
  end
  
  def search_share
    @shares = @search.shares(@page)
  end
  
  def search_group
    @groups = @search.groups(@page)
  end
  
  def search_topic
    @topics = @search.topics(@page)
  end
  
  def search_school
    @map_center = Geo::DEFAULT_CENTER
    @schools = @search.schools(@page)
    
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
