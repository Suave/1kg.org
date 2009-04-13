require 'json'
class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  include ApplicationHelper

  def index
    @schools = School.recent_upload
    
    respond_to do |format|
      format.html {
        @topics = Topic.last_10_updated_topics(SchoolBoard)
        @photos = Photo.find(:all, :conditions => ["photos.school_id is not null"], :order => "updated_at desc", :limit => 12)
        
      }
      format.json {
        @schools_json = []
        @schools.each do |school|
          @schools_json << {:id => school.id, 
                            :name => school.title,
                            :addr => school.basic.address,
                            :intro => "#{school.basic.level_amount}年级, #{school.basic.class_amount}班级, #{school.basic.student_amount}学生, #{school.basic.teacher_amount}老师", 
                            :times => school.visitors.count,
                            :shares => school.shares.count
                            }
        end
        render :json => @schools_json
      }
      
    end
                                 
  end
  
  def all
    list(true)
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
    if params[:step] == 'basic'
      @school = School.new
      @school.build_basic
      render :action => "basic"
      
    elsif params[:step] == 'traffic'
      @school = School.find(params[:sid])
      @school.build_traffic
      render :action => "traffic"
      
    elsif params[:step] == 'need'
      @school = School.find(params[:sid])
      @school.build_need
      render :action => "need"
      
    elsif params[:step] == 'other'
      @school = School.find(params[:sid])
      @school.build_contact
      @school.build_local
      @school.build_finder
      render :action => "other"
      
    else
      @school = School.new
      @school.build_basic
      render :action => "basic"
    end
  end
  
  def create
    if params[:step] == 'basic'
      @school = School.new(params[:school])
      @school.user = current_user
      @school.save!
      flash[:notice] = "学校基本信息已保存，请继续填写学校交通信息"
      redirect_to new_school_url(:step => 'traffic', :sid => @school.id)
      
    elsif params[:step] == 'traffic'
      @school = School.find(params[:school][:id])
      @school.traffic = SchoolTraffic.new
      @school.traffic.tag_list = params[:school][:school_traffic][:sight]
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校交通信息已经保存，请继续填写学校的需求信息"      
      redirect_to new_school_url(:step => 'need', :sid => @school.id)
      
    elsif params[:step] == 'need'
      @school = School.find(params[:school][:id])
      @school.need = SchoolNeed.new

      new_tag_list = ""
      %w(urgency book stationary sport cloth accessory course teacher other).each do |need|
        new_tag_list += params[:school][:school_need][need.to_sym] unless params[:school][:school_need][need.to_sym].nil?
      end

      @school.need.tag_list = new_tag_list
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校需求信息已经保存，请填写最后一项"
      redirect_to new_school_url(:step => 'other', :sid => @school.id)
      
    elsif params[:step] == 'other'
      @school = School.find(params[:school][:id])
      @school.update_attributes!(params[:school])
      flash[:notice] = "提交学校成功，谢谢你！"
      redirect_to school_url(@school)
    else
      # TODO add some catch exception
    end
  end
  
  def edit
    @school = School.find(params[:id])
    if params[:step] == 'basic'
      render :action => "edit_basic"
    elsif params[:step] == 'traffic'
      render :action => "edit_traffic"
    elsif params[:step] == 'need'
      render :action => "edit_need"
    elsif params[:step] == 'other'
      render :action => "edit_other"
    else
      render :action => "edit_basic"
    end
  end
  
  def update
    @school = School.find(params[:id])

    if params[:step] == 'basic'
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校基本信息修改成功！"
      render :action => "edit_traffic"

    elsif params[:step] == 'traffic'
      @school.traffic.tag_list = params[:school][:school_traffic][:sight]
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校交通信息修改成功！"
      render :action => "edit_need"
      
    elsif params[:step] == 'need'
      new_tag_list = ""
      %w(urgency book stationary sport cloth accessory course teacher other).each do |need|
        new_tag_list += params[:school][:school_need][need.to_sym] unless params[:school][:school_need][need.to_sym].nil?
      end

      @school.need.tag_list = new_tag_list
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校需求信息修改成功！"
      render :action => "edit_other"
      
    elsif params[:step] == 'other'
      @school.update_attributes!(params[:school])
      flash[:notice] = "学校信息修改完成！"
      redirect_to school_url(@school)
    end
  end
  
  
  
  def show
    @school = School.find(params[:id])
    @visitors = @school.visitors
    @followers = @school.interestings
    @shares = @school.shares
    
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
  
  
  def info
    @school = School.find(params[:id])
    
    if params[:type] == "traffic"
      @type = "traffic"
      @traffic = @school.traffic
    elsif params[:type] == "need"
      @type = "need"
      @need = @school.need
    elsif params[:type] == "local"
      @type = "local"
      @local   = @school.local
    elsif params[:type] == "contact"
      @type = "contact"
      @contact = @school.contact
      @finder  = @school.finder
    else
      # params[:type] == 'basic' or whatever
      @type = "basic"
      @basic = @school.basic
    end
  end
  
  def validate
    @school = School.find(params[:id])
    if params[:t] == 'add'
      @school.update_attributes!(:validated => true)
      flash[:notice] = "已经通过验证"
      
    elsif params[:t] == 'remove'
      @school.update_attributes!(:validated => false)
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
  
  
end