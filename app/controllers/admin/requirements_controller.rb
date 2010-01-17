class Admin::RequirementsController < Admin::BaseController
  before_filter :find_requirement_type
  
  def index
    @requirements = @type.requirements.find :all, :order => "created_at desc"
  end
  
  def new
    @requirement = Requirement.new
  end
  
  def create
    @requirement = Requirement.new(params[:requirement])
    @requirement.type = @type
    @requirement.save!
    flash[:notice] = "Buck 创建成功"
    redirect_to admin_requirement_type_requirements_url(@type)
  end
  
  def edit
    @requirement = Requirement.find(params[:id])
  end
  
  def update
    @requirement = Requirement.find(params[:id])
    @requirement.update_attributes!(params[:requirement])
    flash[:notice] = "Buck 更新成功"
    redirect_to admin_requirement_type_requirements_url
  end
  
  def destroy
    @requirement = Requirement.find(params[:id])
    @requirement.destroy
    flash[:notice] = "Buck 删除成功"
    redirect_to admin_requirement_type_requirements_url
  end
  
  def show
    @requirement = Requirement.find(params[:id])
    @stuffs = @requirement.donations.find :all, :include => [:user, :school]
    
    respond_to do |format|
      format.html
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          @stuffs.each do |stuff|
            csv << stuff.code
          end
        end
        
        send_data csv_string,
                  :type => 'text/csv; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=passwords.csv"
      end
    end
  end
  
  
  
  
  private
  def find_requirement_type
    @type = RequirementType.find(params[:requirement_type_id])
  end
  
end