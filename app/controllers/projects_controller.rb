class ProjectsController < ApplicationController
  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]

  def index
    @validated_projects = Project.validated.find :all, :order => "created_at desc"
  end
  
  def new
      @project = Project.new(:feedback_require => "")
  end



end