require 'json'
class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :info_window]
  
  skip_filter :verify_authenticity_token, :only => [:update]
  
  include ApplicationHelper

  def index
    respond_to do |format|
      @schools = School.recent_upload
      format.html {
        @topics = Topic.last_10_updated_topics(SchoolBoard)
        @photos = Photo.find(:all, :conditions => ["photos.school_id is not null"], :order => "updated_at desc", :limit => 12)
        
      }
      format.json {
        @schools = School.all
        @schools_json = []
        @schools.each do |school|
          @schools_json << {:i => school.id,
                            :la => school.basic.latitude,
                            :lo => school.basic.longitude
                            }
        end
        render :json => @schools_json
      }
    end
  end
  
  def info_window
    @school = School.find(params[:id])
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic

    respond_to do |format|
      format.html {render :layout => false}
    end
  end
  
  def all
    redirect_to geos_path
  end
  
  def unconfirm
    list(false)
  end
  
  def archives
    
  end
  
  def list(validated = true)
    provinces     = Geo.roots
    @all_provinces = []
    @output        = []

    provinces.each do |province|
      areas = province.children
      unless areas.empty?
        schools = School.find(:all, 
                              :conditions => ["schools.deleted_at is NULL and schools.meta=? and schools.validated = ? and schools.geo_id in (?)",false, validated, areas], 
                              :order => "schools.geo_id asc, schools.updated_at desc")

        unless schools.empty?
          @output[province.id] = schools
        end
      end
    end
    provinces.each do |province|
      unless @output[province.id].blank?
        @all_provinces << province
      end
    end
  end
  
  # 给出指定日期的所有学校
  def show_date
    @date = "#{params[:year]}年#{params[:month]}月"
    if params[:valid] == "false"
      @schools = School.show_date(params[:year],params[:month],params[:day],false)
      render :template => "schools/show_invalid"
    else
      @schools = School.show_date(params[:year],params[:month],params[:day],true)
      render :template => "schools/show_valid"
    end 
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "没有找到你查找的学校"
    redirect_to schools_path
  end
  
  def new
    @school = School.new
    @step = 'basic'
  end
  
  def create
    if params[:step] == 'basic'
      @school = School.new(params[:school])
      @school.user = current_user
      
      begin
        
        @school.save!
        flash[:notice] = "学校基本信息已保存，请继续填写学校交通信息"
        redirect_to edit_school_url(@school, :step => 'traffic')
        
      rescue ActiveRecord::RecordInvalid
                
        render :action => "basic"
        
      end
      
    # elsif params[:step] == 'traffic'
    # 
    #       submit_info "traffic", "need", "学校交通信息已经保存，请继续填写学校的需求信息"
    #       
    #     elsif params[:step] == 'need'
    # 
    #       submit_info "need", "other", "学校需求信息已经保存，请填写最后一项"
    #       
    #     elsif params[:step] == 'other'
    # 
    #       submit_info "other", "done", "提交学校成功，谢谢你！"
    #       
    #     else
      # TODO add some catch exception
    end
  end
  
  def edit
    @school = School.find(params[:id])
    %w(basic traffic need other position).include?(params[:step]) ? @step = params[:step] : @step = "basic"
    render :action => "edit_#{@step}"
  end
  

  def update
    @school = School.find params[:id]
    respond_to do |format|
      format.html do
        if params[:step] == 'basic'

          update_info "basic", "traffic", "学校基本信息修改成功！"

        elsif params[:step] == 'traffic'

          update_info "traffic", "need", "学校交通信息修改成功！"
          
        elsif params[:step] == 'need'

          update_info "need", "position", "学校需求信息修改成功！"
          
        elsif params[:step] == 'other'

          update_info "other", "done", "学校信息修改完成！"
          
        end
        
        if params[:moderator] == 'add'
          user = User.find params[:uid]
        end
      end
      
      # for drag & drop school marker
      format.js do
        @school.basic.update_attributes(:latitude => params[:latitude], :longitude => params[:longitude])
        render :update do |page|
          page['map_message'].replace_html(:inline => '新位置已经成功保存，<%= link_to "点击此处进入下一步", edit_school_path(@school, :step => "other") %>')
          page['map_message'].visual_effect('highlight')
        end
      end
    end
  end
  
  
  
  def show
    @school = School.find(params[:id])
    
    @traffic = @school.traffic
    @need = @school.need
    @local   = @school.local
    @contact = @school.contact
    @finder  = @school.finder
    @basic = @school.basic
    
    if @school.nil? or @school.deleted?
      render_404 and return
    end
    
    @visitors = @school.visitors
    @followers = @school.interestings
    @shares = @school.shares
    @photos = @school.photos
    if logged_in?
      @visited = Visited.find(:first, :conditions => ["user_id=? and school_id=? and status=?", current_user, @school.id, Visited.status('visited')])
    end
    
    @board = SchoolBoard.find(:first, :conditions => {:school_id => @school.id})
    unless @board.blank?
      @board = @board.board
      @topics = @board.latest_topics
    end 
    
  end
  
  def destroy
    @school = School.find(params[:id])
    @school.update_attributes!(:deleted_at => Time.now)
    flash[:notice] = "成功删除学校"
    redirect_to schools_url
  end
  
  def validate
    @school = School.find(params[:id])
    if params[:t] == 'add'
      @school.update_attributes!(:validated => true, :validated_at => Time.now, :validated_by_id => current_user.id )
      flash[:notice] = "已经通过验证"
      
    elsif params[:t] == 'remove'
      @school.update_attributes!(:validated => false, :validated_at => Time.now, :validated_by_id => current_user.id )
      flash[:notice] = "已经取消验证"
      
    else
      flash[:notice] = "错误"
      
    end
    redirect_to school_url(@school)
  end
  
  def visited
    @school = School.find(params[:id])
    if @school.visited?(current_user) == false
      Visited.create!(:user_id => current_user.id,
                      :school_id => @school.id,
                      :status => Visited.status('visited'),
                      :visited_at => params[:visited][:visited_at]
                     )
    
    elsif @school.visited?(current_user) == 'interesting'
      visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
      visited.update_attributes!(:status => Visited.status('visited'),
                                 :visited_at => params[:visited][:visited_at]
                                )
    
    elsif @school.visited?(current_user) == 'visited'
      visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
      visited.update_attributes!(:visited_at => params[:visited][:visited_at])
      
    end
    redirect_to school_url(@school)
  end
  
  def interest
    @school = School.find(params[:id])
    unless @school.visited?(current_user)
      Visited.create!(:user_id => current_user.id, :school_id => @school.id, :status => Visited.status('interesting'))
    else
      flash[:notice] = "你已经选择过感兴趣或去过这所学校了"
    end
    redirect_to school_url(@school)
  end
  
  def novisited
    @school = School.find(params[:id])
    visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", current_user.id, @school.id])
    visited.destroy if visited
    redirect_to school_url(@school)
  end
  
  def moderator
    @school = School.find params[:id]
    @moderators = User.moderators_of @school
    @candidates = @school.visitors + @school.interestings - @moderators
  end
  
  
  # 提供给国旅的学校列表
  def cits
    provinces = %w(3 146 15 40 164 27)
    geo_ids = [1, 2] #天津
    provinces.each do |p|
      Geo.find(p).children.collect {|c| geo_ids << c}
    end
    @schools = School.find(:all, :conditions => ["geo_id in (?)", geo_ids], 
                                           :include => [:traffic, :basic, :geo, :county])
  end
  
  
  private
  # def submit_info(current_step, next_step, msg)
  #   @school = School.find params[:id]
  #   
  #   begin
  #     
  #     @school.update_attributes!(params[:school])
  #     flash[:notice] = msg      
  #     redirect_to next_step == "done" ? school_url(@school) : new_school_url(:step => next_step, :sid => @school.id)
  #     
  #   rescue ActiveRecord::RecordInvalid
  #     
  #     render :action => current_step
  #     
  #   end
  # end
  
  def update_info(current_step, next_step, msg)
    begin
      @school.update_attributes!(params[:school])
      flash[:notice] = msg
      next_step == "done" ? redirect_to(school_url(@school)) : redirect_to(edit_school_url(@school, :step => next_step))
      
    rescue ActiveRecord::RecordInvalid
      
      render :action => "edit_#{current_step}"
    
    end
  end
  
end