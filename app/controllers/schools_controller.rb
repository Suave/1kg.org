class SchoolsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  def index
    
  end
  
  def new
    @school = School.new
    @school.build_basic
  end
  
  def create
    #logger.info("BEFORE NEW")
    @school = School.new(params[:school])
    #logger.info("AFTER NEW")
    #@basic  = @school.build_basic(params[:school_basic])
    @school.user = current_user
    @school.save!
    flash[:notice] = "提交成功"
    redirect_to schools_url
  end
  
end