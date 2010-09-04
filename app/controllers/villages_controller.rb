class VillagesController < ApplicationController
  before_filter :find_village, :except => [:index,:new,:create]
  before_filter :login_required, :except => [:show,:index]
  before_filter :check_permission ,:only => [:edit,:destory,:update,:location,:main_photo]
  
  def show
    @executions = @village.executions
    @shares = @executions.map{|e| e.shares}.flatten
    @photos = @executions.map{|e| e.photos}.flatten
    @execution = @executions.find(:first,:conditions => {:project_id => 6}) #获取灾情调研项目
  end
  
  def new
    @village =Village.new
  end
  
  def create
    @village = Village.new(params[:village])
    @village.user = current_user
    respond_to do |format|
      if @village.save
        flash[:notice] = "村庄创建成功,请标记村庄的具体位置"
        format.html{redirect_to location_village_url(@village)}
      else
        flash[:notice] = "请检查所有必填项是否填写正确"
        format.html{render :action => "new"}
      end
    end
  end
  
  def update
    @village.update_attributes(params[:village])
    
    respond_to do |format|
      format.html do
        if params[:next] == 'main_photo'
          flash[:notice] = "请上传一张村庄的照片"
          redirect_to main_photo_village_url(@village)
        else
          redirect_to village_url(@village)
        end
      end    
    # for drag & drop school marker
      format.js do
        @village.basic.update_attributes( :latitude => params[:latitude], 
                                         :longitude => params[:longitude],
                                         :marked_at => Time.now,
                                         :marked_by_id => current_user.id )
      end
    end  
  end
  
  def main_photo
  end
  
  def location
  end
    
  def join_research
    #南都调研项目的特殊参加流程
    if @execution = @village.executions.find(:first,:conditions => {:project_id => 6}) #获取灾情调研项目
      flash[:notice] = "村庄已经参加了调研项目"
    else
      @execution = Execution.new(:user_id => current_user.id,
                                 :village_id => @village.id,
                                 :project_id => 6,  #南都项目的id
                                 :reason => '　',
                                 :plan => '　',
                                 :telephone => '　',
                                 :state => 'going'
                                 )
      @execution.save
      flash[:notice] = "参加成功，请在项目反馈中上传你的调研照片和分享（可以从调研项目页面来到这里）"
      redirect_to  project_execution_url(@execution.project,@execution)
    end
  end
  
  
  def large_map
    @map_center = Geo::DEFAULT_CENTER
    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def check_permission
    if @village.user == current_user
    elsif current_user.admin?
    else
      flash[:notice] = "你没有权限进行此操作"
      redirect_to co_donation_url(@co_donation)
    end
  end
  
  private
  def find_village
    @village = Village.find(params[:id])
  end
end