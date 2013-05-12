# -*- encoding : utf-8 -*-
module Util
    
  def avatar_convert(model_name, attribute_name)
    # convert user's avatar to gif format, thanks for Robin Lu
    iconfile = params[model_name][attribute_name]
    unless iconfile.blank?
      # if user upload avatar, convert file format
      img = ::Magick::Image::from_blob(iconfile.read).first
      img.crop_resized!(72,72)
      filename = File.join(RAILS_ROOT + "/public/#{model_name}/#{attribute_name}/tmp", 'icon.gif')
      img.write(filename)
      iconfile = File.open(filename)
      params[model_name][attribute_name] = iconfile
    end
  end
  
  def delete_all(klass, id_hash)
    if id_hash.blank?
      flash[:notice] = "请选择要删除的条目"
    else
      delete_ids = id_hash.collect{|k,v| v.to_i}
      klass.destroy delete_ids
      flash[:notice] = "批量删除成功"
    end
  end
end
