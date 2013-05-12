# -*- encoding : utf-8 -*-
module StuffUtil
  def set_message_and_redirect_to_index(msg = "")
    flash[:notice] = msg
    redirect_to index_path
  end
end
