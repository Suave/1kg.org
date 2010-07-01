class TeamsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update,]
  
  def index
  end
  
  def show
    @team = Team.find(params[:id])
  end
  
  def create
    @team = Team.new(params[:team])
    @team.user_id = current_user.id
  
    respond_to do |want|
      if @team.save
        #demo版本暂时没有验证，后续开发中需要等待验证
        flash[:notice] = "申请成功"
        want.html { redirect_to @team }
      else
        want.html { render 'new' }
      end
    end
  end
  
end