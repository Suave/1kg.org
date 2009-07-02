class Admin::SchoolsController < Admin::BaseController
  before_filter :find_school, :except => :index
  
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