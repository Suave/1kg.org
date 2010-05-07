class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy, :revert]
  before_filter :check_category, :only => [:category, :new]
  
  uses_tiny_mce :options => { :theme => 'advanced',
  :browsers => %w{msie gecko safari},   
  :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => true,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => ["undo,redo,|,cut,copy,paste,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,|,image,media,|,code"],
  :theme_advanced_buttons2 => [],
  :language => :zh,
  :plugins => %w{contextmenu media advimage paste fullscreen} }, :only => [:new, :create, :edit, :update]
  
  def index
    @games = {}
    @categories = GameCategory.all
    
  end
  
  def category
    @games = find_by_slug
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
    
    respond_to do |want|
      if @game.update_attributes!(params[:game])
        want.html {redirect_to @game}
      else
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