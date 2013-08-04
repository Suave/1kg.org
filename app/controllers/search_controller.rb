# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def show
    @type_hash = {'activity' => Activity,'group' => Group,'user' => User,'school' => School,'topic' => Topic}
    if params[:keywords].present? && @type_hash[params[:type]].present?
    @keywords = params[:keywords].split.join('+')
      model = @type_hash[params[:type]]
      @result = model.search(@keywords,:page => (params[:page] || 1),:per_page => 10,:retry_stale => true)
      if model == School
        @map_center = Geo::DEFAULT_CENTER
        @json  = [] 
        @result.compact.each do |school|
            next if school.basic.blank?
              @json << {:i => school.id,
                       :t => school.icon_type,
                       :n => school.title,
                       :a => school.basic.latitude,
                       :o => school.basic.longitude
                       }
            end
      end
    else
      flash[:notice] = "输入关键词"
    end
  end
  
  private
  def search_activity
    @activities = @search.activities(@page, 14)
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
