# -*- encoding : utf-8 -*-
class VillagesController < ApplicationController
  before_filter :find_village, :except => [:index,:new,:create]
  before_filter :login_required, :except => [:show,:index,:large_map]
  before_filter :check_permission ,:only => [:edit,:destory,:update,:location,:main_photo]
  
  def show
    @executions = @village.executions
    @topics = @executions.map{|e| e.topics}.flatten
    @photos = @executions.map{|e| e.photos}.flatten
    @execution = @executions.find(:first,:conditions => {:project_id => 6}) #获取灾情调研项目
  end
  
   def new
    %w(basic need position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = 'basic'
    if @step == 'basic'
      @village = Village.new
    else
      @village = Village.find(params[:id])
    end  
  end
  
  def edit
    %w(basic need position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = 'basic'
  end
  
  def create
    @village = Village.new(params[:village])
    @village.user = current_user
    respond_to do |format|
      if @village.save
        flash[:notice] = "村庄创建成功,请标记村庄的具体位置"
        format.html{redirect_to new_village_url(:step => 'position',:id => @village.id,:new=> true)}
      else
        @step = 'basic'
        flash[:notice] = "请检查所有必填项是否填写正确"
        format.html{render :action => "new"}
      end
    end
  end
  
  def update
    @village.update_attributes(params[:village])
    
    respond_to do |format|
      format.html do
        if params[:new] == 'true'
          if params[:step] == 'basic'
            update_info "basic", "position", "村庄信提交成功！"
          elsif params[:step] == 'position'
            update_info "position", "need", "标记村庄位置成功！"
          elsif params[:step] == 'need'
            update_info "need", "mainphoto", "村庄需求信息提交成功！"
          elsif params[:step] == 'mainphoto'
            update_info('mainphoto', 'done', "所有村庄信息已经完成，谢谢你的提交，之后你还可以继续更新村庄的信息。")
          end
        else 
          %w(basic need position mainphoto).include?(params[:step]) ? @step = params[:step] : @step = "basic"
          if @step == 'mainphoto'
            update_info(@step, nil, "你的修改已经保存，可以继续修改其他内容，或 <a href='/villages/#{@village.id}'>回到学校</a>。")
          else
            update_info(@step, nil, "你的修改已经保存，可以继续修改，或 <a href='/villages/#{@village.id}'>回到村庄页面</a>。")
          end
          
        end
      end    
    # for drag & drop village marker
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
  
  
  def update_info(current_step, next_step, msg)
    begin
      @village.update_attributes!(params[:village])
      flash[:notice] = msg
        if next_step
          next_step == "done" ? redirect_to(village_url(@village)) : redirect_to(new_village_url(:step => next_step,:id => @village.id,:new => true))
        else
          if current_step == "need"
            @village.need.update_attributes!(:updated_at => Time.now)
          elsif current_step == "basic"
            @village.basic.update_attributes!(:updated_at => Time.now)
          end
          redirect_to(edit_village_url(@village, :step => current_step))
        end    
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = '请检查所有必填项是否填写正确'
      if next_step
        @step = current_step
        render :action => "new"
      else
        @step = current_step
        render :action => "edit"
      end
    end
  end
  
end
