class TeamsController < ApplicationController
  before_filter :find_team, :except => [:new, :create, :index]
  before_filter :login_required, :only => [:new, :create, :edit, :update,:destory]
  
  def index
  end
  
  def show
  end

  def new
    @team = Team.new
  end
  
  def create
    @team = Team.new(params[:team])
    @team.user_id = current_user.id
  
    respond_to do |want|
      if @team.save
        flash[:notice] = "你的团队申请已经发出，我们会尽快审核你的申请，一经通过会有站内信通知你，注意查收。"
        want.html { redirect_to teams_url }
      else
        want.html { render 'new' }
      end
    end
  end
  
  private
  
  def find_team
    @team = Team.validated.find(params[:id])
  end
  
  def check_permission
    
  end
  
end