class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy, :revert]
  before_filter :check_category, :only => [:category, :new]
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @games = {}
    @categories = GameCategory.all
  end
  
  def show
    @game = Game.find(params[:id])
    @comments = @game.comments.find(:all,:include => [:user,:commentable]).paginate :page => params[:page] || 1, :per_page => 15
    @game.revert_to(params[:version]) if params[:version]
  end
  
  def new
    @game = Game.new(:game_category_id => @category.id)
  end
  
  def category
    @games = @category.games
  end
  
  def create
    @game = Game.new(params[:game])
    @game.user_id = current_user.id
    params[:game]["references_attributes"].reject! {|r| r[:name].blank? || r[:link].blank?}

    respond_to do |want|
      if @game.save
        want.html { redirect_to  @game }
      else
        @category = GameCategory.find_by_id(@game.game_category_id)
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
    params[:game]["references_attributes"].reject! {|r| r[:name].blank? || r[:link].blank?}    
    
    respond_to do |want|
      if @game.update_attributes(params[:game])
        want.html {redirect_to @game}
      else
        raise @game.errors.full_messages.to_s
        want.html {render 'edit'}
      end
    end
  end
  
  def versions
    @game = Game.find(params[:id])
  end
  
  def revert
    @game = current_user.games.find(params[:id])
    @game.revert_to(params[:version])
    @game.comment = "管理员回滚到版本#{params[:version]}"
    @game.save(false)
    
    respond_to do |want|
      want.html {redirect_to game_path(@game)}
    end
  end
  
  def destroy
    @game = current_user.games.find(params[:id])
    @game.destroy

    respond_to do |want|
      want.html {redirect_to games_path}
    end
  end
  
  private
  
  def check_category
    if params[:tag] && GameCategory.all.map(&:slug).include?(params[:tag])
      @category = GameCategory.find_by_slug(params[:tag])
    else
      render_404
    end
    
  end
  
end