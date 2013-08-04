# -*- encoding : utf-8 -*-
module Minisite::Postcard::DashboardHelper
  def postcard_avatar_for(user, size)
    if user.avatar.blank?
      image_tag "/images/postcard/avatar_#{size}.png", :class => "avatar", :alt => user.login
    else
      image_tag url_for_file_column(user, :avatar, size), :class => "avatar", :alt => user.login
    end
  end
  
end
