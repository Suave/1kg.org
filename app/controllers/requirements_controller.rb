class RequirementsController < ApplicationController
  layout 'donation'
  
  def show
    @requirement = Requirement.find(params[:id])
  end
end