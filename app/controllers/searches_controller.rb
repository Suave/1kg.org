class SearchesController < ApplicationController
  def show
    @map_center = Geo::DEFAULT_CENTER
    @search = Search.new(:q => params[:q], :title => params[:title], :city => params[:city],
                          :need => params[:need], :address => params[:address],
                          :class_amount => params[:class_amount],
                          :student_amount => params[:student_amount],
                          :has_library =>  params[:has_library],
                          :has_pc => params[:has_pc])
    @schools = @search.schools(params[:page])
    
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
        
    respond_to do |format|
      format.html
    end
  end
end
