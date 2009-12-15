class TagsController < ApplicationController
  def index
    respond_to do |format|
      if params[:tag]
        format.html {redirect_to tag_path(:tag => params[:tag])}
      else
        @tags = SchoolNeed.tag_counts + SchoolGuide.tag_counts
        format.html
      end
    end
  end
  
  def show
    @tag = params[:tag]
    @school_needs = SchoolNeed.find_tagged_with(params[:tag])
    # 需要优化
    @schools = @school_needs.map(&:school).paginate(:per_page => 10, :page => params[:school_page], :conditions => ['deleted_at = ?', nil])
    @shares = Share.find_tagged_with(params[:tag]).paginate(:per_page => 10, :page => params[:share_page])
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
