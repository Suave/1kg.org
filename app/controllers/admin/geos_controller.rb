class Admin::GeosController < Admin::BaseController
  def index
  end
  
  def new
    @parent = Geo.find(params[:geo]) if params[:geo]
    @geo = Geo.new
  end
  
  def create
    @geo = Geo.new(params[:geo])
    @geo.save!
    
    # setup parent
    unless params[:parent].blank?
      @parent = Geo.find(params[:parent]) 
      @geo.move_to_child_of @parent
    end
    
    flash[:notice] = "添加成功"
    redirect_to admin_geos_url
  end
  
  def edit
    @geo = Geo.find(params[:id])
    @children = @geo.children
  end
  
  def update
    @geo = Geo.find(params[:id])
    @geo.update_attributes!(params[:geo])
    flash[:notice] = "修改成功"
    redirect_to admin_geos_url
  end
  
  def destroy
    # TODO need more strict validation before destroy
    # because the geo has many schools, activities, discussion, child city/village
    @geo = Geo.find(params[:id])
    @geo.destroy
    flash[:notice] = "删除成功"
    if @geo.parent
      redirect_to edit_admin_geo_url(@geo.parent.id)
    else
      redirect_to admin_geos_url
    end
  end
  
  
  private
=begin
  def migration
    provinces = Area.find(:all, :conditions => "parent_id is null or parent_id=0")
    provinces.each do |province|
      new_province = Geo.new(:name => province.title, :zipcode => province.zipcode)
      new_province.save!

      cities = Area.find(:all, :conditions => ["parent_id = ?", province.id])
      cities.each do |city|
        new_city = Geo.new(:name => city.title, :zipcode => city.zipcode)
        new_city.save!
        new_city.move_to_child_of new_province
      end
    end
  end
=end
end