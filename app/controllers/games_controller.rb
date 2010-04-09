class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update]
  
  def index
    @games = Game.paginate(:page => params[:page], :per_page => 20, :order => 'updated_at DESC')
  end
  
  def show
    @game = Game.find(params[:id])
    @game.revert_to(params[:version]) if params[:version]
  end
  
  def new
    @game = Game.new
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
end