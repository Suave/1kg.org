class TagsController < ApplicationController
  def index
    respond_to do |format|
      if params[:tag]
        format.html {redirect_to tag_path(:tag => params[:tag])}
      else
        @tags = SchoolNeed.tag_counts
        format.html
      end
    end
  end
  
  def show
    @tag = params[:tag]
    @school_needs = SchoolNeed.find_tagged_with(params[:tag], :include => [:school => [:basic]])
    
    
    respond_to do |wants|
      wants.html do
        # 需要优化
        @schools = @school_needs.map(&:school).paginate(:per_page => 20, :page => params[:page], :conditions => ['deleted_at = ?', nil])
        @map_center = Geo::DEFAULT_CENTER
      end
      
      wants.json do
        @schools = @school_needs.map(&:school).compact
        @schools_json = []
        @schools.each do |school|
          @schools_json << {:i => school.id,
                           :t => school.icon_type,
                           :n => school.title,
                           :a => school.basic.latitude,
                           :o => school.basic.longitude
                          }
        end
        render :json => "var schools =" + @schools_json.to_json
      end
    end
  end
  
  def needs
    respond_to do |format|
      if params[:tag]
        format.html {redirect_to tag_path(:tag => params[:tag])}
      else
        @tags = SchoolNeed.tag_counts
        @book_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::BOOK_NEEDS])
        @stationary_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::STATIONARY_NEEDS])
        @sport_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::SPORT_NEEDS])
        @cloth_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::CLOTH_NEEDS])
        @accessory_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::ACCESSORY_NEEDS])
        @course_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::COURSE_NEEDS])
        @medicine_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::MEDICINE_NEEDS])
        @hardware_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::HARDWARE_NEEDS])
        @teacher_tags = SchoolNeed.tag_counts(:conditions => ["#{Tag.table_name}.name in (?)", SchoolNeed::TEACHER_NEEDS])
        format.html
      end
    end
  end
end
