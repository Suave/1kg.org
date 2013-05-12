# -*- encoding : utf-8 -*-
class ThemesController < ApplicationController
  
  
  
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new_topic, :new, :create, :edit, :update]
  
  def index
    @themes = Theme.all
  end
  
  def show
    @theme = Theme.find(params[:id])
    @topics = @theme.topics.paginate(:page => params[:page], :per_page => 20)
  end
 
end
