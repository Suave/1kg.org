class GuidesController < ApplicationController
  before_filter :set_school
  before_filter :login_required, :except => ['show']
  
  def new
    @school_guide = SchoolGuide.new(:school_id => @school.id)
  end
  
  def create
    @school_guide = @school.guides.build(params[:school_guide].merge({:user_id => current_user.id}))
    
    respond_to do |format|
      if @school_guide.save
        flash[:notice] = '攻略成功提交'
        format.html {redirect_to school_path(@school)}
      else
        format.html {render :action => 'new'}
      end
    end
  end
  
  def edit
    @school_guide = current_user.guides.find(params[:id])
  end
  
  def update
    @school_guide = current_user.guides.find(params[:id])
    
    respond_to do |format|
      if @school_guide.update_attributes(params[:school_guide])
        flash[:notice] = '攻略更新成功'
        format.html { redirect_to school_guide_path(@school, @school_guide)}
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def show
    @school_guide = SchoolGuide.find_by_id(params[:id])
    
    respond_to do |format|
      if @school_guide
        @school_guide.increment!(:hits)
        @comments = @school_guide.comments.available.paginate :page => params[:page] || 1, :per_page => 15
        @comment = GuideComment.new
        format.html
      else
        flash[:notice] = '对不起攻略不存在'
        format.html { redirect_to root_path }
      end
    end
  end
  
  def destroy
    @school_guide = current_user.guides.find_by_id(params[:id])
    @school_guide.destroy if @school_guide
    
    respond_to do |format|
      format.html {redirect_to school_path(@school)}
    end
  end
  
  private
  def set_school
    @school = School.find_by_id(params[:school_id])
  end
end
