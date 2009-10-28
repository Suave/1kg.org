class SearchesController < ApplicationController
  def create
    redirect_to search_path(params[:search][:keywords])
  end
  
  def show
    @keywords = params[:id]
    @search = Search.new(:keywords => @keywords)
    @schools = School.search(@keywords, params[:page])
    
    respond_to do |format|
      format.html
    end
  end
end
