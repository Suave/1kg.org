class RequirementsController < ApplicationController
  def show
    @requirement = Requirement.find(params[:id])
  end
end