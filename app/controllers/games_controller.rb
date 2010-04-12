class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update]
  before_filter :check_category, :except => [:index,:show,:edit,:update]
  
  @@categories = {
    :music => '音乐课',
    :art => '美术课',
    :science => '环境科普教育',
    :language => '语言类活动',
    :health => '心理卫生健康课',
    :sprit =>'心灵教育',
    :sports =>'健身活动',
    :reading =>'读书活动',
    :safety =>'法律安全知识',
    :computer =>'科技教育'}
  
  def index
    
    @categories = @@categories.to_a
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
    
    @games = Game.find(:all,:conditions => {:category => @category})
  end
  
  def create
    check_category
    @game = Game.new(params[:game])
    @game.user_id = current_user.id
    @game.category = @category
    respond_to do |want|
      if @game.save
        want.html { redirect_to  "/games/category/#{@category}" }
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
      if @game.update_attributes!(params[:game])
        want.html {redirect_to @game}
      else
        want.html {render 'edit'}
      end
    end
  end
  
  private
  
  def check_category
    if params[:tag] && @@categories.keys.include?(params[:tag].to_sym)
      @category = params[:tag]
      @title = @@categories[params[:tag].to_sym]
    else
      
      render_404
    end
    
  end
  
end