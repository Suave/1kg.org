# -*- encoding : utf-8 -*-
class ManagementsController < ApplicationController
  before_filter :login_required

  def create
    manageable = params[:manageable_type].constantize.find(params[:manageable_id])
    if manageable.managed_by?(current_user) || current_user.is_admin
      management = Management.new(:manageable_id => manageable.id,:manageable_type => manageable.class.name,:user_id => params[:user_id])
      management.save
      flash[:notice] = "添加成功"
    end
    redirect_to url_for([:managers,management.manageable])
  end

  def destroy
    management = Management.find(params[:id])
    manageable = management.manageable
    if manageable.managed_by?(current_user) || current_user.is_admin
      if manageable.managements.count == 1
        flash[:notice] = "至少有一位管理员"
      else
        management.destroy
        flash[:notice] = "删除成功"
      end
    end
    redirect_to url_for([:managers,manageable])
  end
end
