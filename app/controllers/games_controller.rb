class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update]
  @@categorys = {
    :music => '音乐课',
    :art => '美术/手工课',
    :science => '环境科普教育（环保+科普教育）',
    :language => '语言类活动 （普通话+英语课）',
    :health => '心理卫生健康课',
    :sprit =>'心灵教育（励志课+思想品德课）',
    :sports =>'健身活 动（体育课+广播体操）',
    :reading =>'读书活动（阅读教育活动）',
    :safety =>'法律安全知识（法律常识+安全自救培训）',
    :computer =>'科技教育（电脑课）'}
  
  def index
    
    @categorys = @@categorys
    @games = Game.paginate(:page => params[:page], :per_page => 20, :order => 'updated_at DESC')
  end
  
  def show
    @game = Game.find(params[:id])
    @game.revert_to(params[:version]) if params[:version]
  end
  
  def new
    @game = Game.new
  end
  
  def category
    check_category
  end
  
  def create
    @game = Game.new(params[:game])
    @game.user_id = current_user.id
    
    respond_to do |want|
      if @game.save
        want.html { redirect_to games_path }
      else
        want.html { render 'new' }
      end
    end
  end
  
  def edit
    @game = Game.find(params[:id])
  end
  
  def update
    @game = Game.find(params[:id])
    @game.user_id = current_user.id
    
    respond_to do |want|
      if @game.update_attributes(params[:game])
        want.html {redirect_to @game}
      else
        want.html {render 'edit'}
      end
    end
  end
  
  private
  
  def check_category
    if @@categorys.keys.include?(params[:tag].to_sym)
      @category = params[:tag]
      @title = @@categorys[params[:tag].to_sym]
    else
      render_404
    end
    
  end
  
end