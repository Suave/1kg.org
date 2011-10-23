class SearchesController < ApplicationController
  def show
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
  
  def search_user
    @users = @search.users(@page)
  end
  
  def search_school
    @map_center = Geo::DEFAULT_CENTER
    @schools = @search.schools(@page)
    
    @json = []
    @schools.compact.each do |school|
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
