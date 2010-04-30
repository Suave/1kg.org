class Admin::RequirementsController < Admin::BaseController
  before_filter :find_requirement_type
  
  def index
    @requirements = @type.requirements.find :all, :order => "created_at desc"
    
    if @type.exchangable?
      render :action => "exchangable_list"
    else
      render :action => "non_exchangable_list"
    end
  end
  
  def new
    @requirement = Requirement.new
  end
  
  def create
    @requirement = Requirement.new(params[:requirement])
    #@requirement.agree_feedback_terms = true
    @requirement.requirement_type = @type
    @requirement.save!
    flash[:notice] = "新需求创建成功"
    redirect_to admin_requirement_type_requirements_url(@type)
  end
  
  def edit
    @requirement = Requirement.find(params[:id])
  end
  
  def approve
    @requirement = Requirement.find(params[:id])
    @requirement.update_attribute(:validated, true)
    @requirement.update_attribute(:validated_at, Time.now)
    @requirement.update_attribute(:status, 1)
    #发站内信通知事批准申请
  
    msg = Message.new
    msg.author_id = 0
    msg.to = [@requirement.applicator_id]
    msg.subject = "为#{@requirement.school.title}的项目申请已通过"
    msg.content = "你好， #{@requirement.applicator.login}：<br/><br/>你为#{@requirement.school.title}( http://www.1kg.org/schools/#{@requirement.school.id} ) 申请的项目：#{@requirement.requirement_type.title}( http://www.1kg.org/projects/#{@requirement.requirement_type.id} )，已经得到了通过。接下来我们会给予你必要的支持，而你需要在项目结束之前完成你的执行计划，并按照项目的反馈要求提供你的报告。<br/><br/>多背一公斤团队"
    msg.save! 
    redirect_to admin_requirement_type_requirements_url(@requirement.requirement_type)
    
  end
  
  def reject
    @requirement = Requirement.find(params[:id])
    @requirement.update_attribute(:validated, false)
    @requirement.update_attribute(:validated_at, nil)
    @requirement.update_attribute(:status, 2)
    redirect_to admin_requirement_type_requirements_url(@requirement.requirement_type)
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
    if @requirement.status
      render :template => "/admin/requirements/school"
    else
    @donations = @requirement.donations.find :all, :include => [:user, :school]
      
      respond_to do |format|
        format.html
        format.csv do
          csv_string = FasterCSV.generate do |csv|
            @donations.each do |donation|
              csv << donation.code
            end
          end
          
          send_data csv_string,
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=passwords.csv"
        end
      end
    end
  end
  
  private
  def find_requirement_type
    @type = RequirementType.find(params[:requirement_type_id])
  end
  
end