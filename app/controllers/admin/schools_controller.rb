class Admin::SchoolsController < Admin::BaseController
  before_filter :find_school, :except => [:index, :import, :create]
  
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
        flash[:notice] = "学校基本信息已保存，请继续填写学校交通信息"
      else
        flash[:notice] = "学校基本信息不完整，请重新填写"
      end
      format.html{redirect_to :back }
    end
  end
  
  def import
    @schools = School.import_from_blog
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
  
  private
  def find_school
    @school = School.find params[:id]
  end
  
  
end