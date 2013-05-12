# -*- encoding : utf-8 -*-
class OauthController < ApplicationController

  def default_callback_url site
    URI.encode url_for(:controller => 'oauth', :action => 'accept')
  end
    
  def accept
    token = OauthToken.find_by_user_id_and_request_key((current_user ? current_user.id : nil), params[:oauth_token])
    access = token.authorize params[:oauth_verifier]
    if token.user_id.nil?
      redirect_to connect_account_path(:oauth_token => params[:oauth_token])
    else
      redirect_to((session[:oauth_refers]||{})[token.site] || '/' )
    end
  end

  def cancel
    token = OauthToken.where(:user_id => current_user.id, :site => params[:site]).first
    if token.destroy
      redirect_to :back  
    else
      render :text => 'fail', :status => 500
    end
  end

  def cancel_all
    if OauthToken.where(:user_id => current_user.id).delete_all
      render :text => 'ok'
    else
      render :text => 'fail', :status => 500
    end
  end
end
