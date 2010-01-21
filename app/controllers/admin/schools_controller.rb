class Admin::SchoolsController < Admin::BaseController
  before_filter :find_school, :except => [:index, :import, :create, :merging, :merge]
  
  def index
    if params[:type].blank? || params[:type] == "validated"
      @type = "validated"
      @schools = School.find(:all, :conditions => {:validated => true, :deleted_at => nil}, :order => "updated_at desc, created_at desc")
      
    elsif params[:type] == "suspend"
      @type = "suspend"
      @schools = School.find(:all, :conditions => {:validated => false, :deleted_at => nil}, :order => "updated_at desc , created_at desc")
      
    elsif params[:type] == "trash"
      @type = "trash"
      @schools = School.find(:all, :conditions => ["deleted_at is not NULL"], :order => "updated_at desc, created_at desc")
      
    end
  end
  
  def show
  end
  
  def create
    @school = School.new(params[:school])
    @school.user_id = 1
    
    respond_to do |format|
      if @school.save
        flash[:notice] = "学校基本信息已保存"
      else
        raise @school.errors.full_messages.to_s
        flash[:notice] = "学校基本信息不完整，请重新填写"
      end
      format.html{redirect_to :back }
    end
  end
  
  def import
    @schools = School.import_from_blog
    @title = params[:title]
    @school = @schools.select {|s| s.title == @title}.first
  end
  
  def destroy
    @school.destroy
    flash[:notice] = "#{@school.title} 的信息已经彻底删除！"
    redirect_to admin_schools_url(:type => "trash")
  end
  
  
  def active
    @school.update_attributes!(:deleted_at => nil)
    flash[:notice] = "已经恢复 #{@school.title}"
    redirect_to admin_schools_url(:type => "trash")
  end
  
  def merging
  end
  
  def merge
    @main_school = School.find(params[:main_school_id])
    @main_id     = @main_school.id
    @sub_school  = School.find(params[:sub_school_id])
    
    # 合并需求
    if @main_school.need && @sub_school.need
      @main_school.need.book += @sub_school.need.book
      @main_school.need.stationary += @sub_school.need.stationary
      @main_school.need.sport += @sub_school.need.sport
      @main_school.need.cloth += @sub_school.need.cloth
      @main_school.need.accessory += @sub_school.need.accessory
      @main_school.need.course += @sub_school.need.course
      @main_school.need.teacher += @sub_school.need.teacher
      @main_school.need.other += @sub_school.need.other
      @main_school.need.medicine += @sub_school.need.medicine
      @main_school.need.hardware += @sub_school.need.hardware
    end
    
    @sub_school.shares.each {|s| s.school_id = @main_id; s.save(false)}
    @sub_school.photos.each {|p| p.school_id = @main_id; p.save(false)}
    @sub_school.donations.each {|s| s.school_id = @main_id; s.save(false)}
    @sub_school.visited.each {|v| v.school_id = @main_id; v.save(false)}
    @sub_school.activities.each {|a| a.school_id = @main_id; a.save(false)}
    
    if @main_school.discussion && @sub_school.discussion
      @sub_school.discussion.board.topics.each do |t|
        t.board_id = @main_school.discussion.board.id
        t.save(false)
      end
    end
    
    #@sub_school.destroy
    @main_school.save(false)
    redirect_to admin_path
  end
  
  private
  def find_school
    @school = School.find params[:id]
  end
  
  
end