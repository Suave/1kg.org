# -*- encoding : utf-8 -*-
class VotesController < ApplicationController
  before_filter :login_required
   
  def create
    @vote = current_user.votes.build(:voteable_type => params[:voteable_type],:voteable_id => params[:voteable_id])
    if @vote.voteable && @vote.save
      flash[:notice] = "推荐成功!" 
      redirect_to @vote.voteable
    else
    end
  end
  
  def destroy
  end
  
end
