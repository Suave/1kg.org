class Admin::GameCategoriesController < Admin::BaseController
  def index
    @categories = GameCategory.all
  end
  
  def new   
  end
  
  def create
    @category = GameCategory.new params[:game_category]
    @category.save!
    flash[:notice] = "<p>成功添分类：#{@category.name}</p>"
    redirect_to admin_game_categories_url()
  end
  
  def edit
    @game_category = GameCategory.find(params[:id])
  end
  
  def destroy
    @game_category = GameCategory.find(params[:id])
    @game_category.destroy
    flash[:notice] = "删除成功"
    redirect_to admin_game_categories_url()
  end
  
  def update
    @category = GameCategory.find(params[:id])
    @category.update_attributes!(params[:game_category])
    flash[:notice] = "更新成功"
    redirect_to admin_game_categories_url
  end
end