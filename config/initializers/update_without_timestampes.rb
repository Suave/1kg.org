# -*- encoding : utf-8 -*-
# 扩展ActiveRecord，增加一个方法，保存时不用更新时间戳
module ActiveRecord
  class Base
    def save_without_timestamping
      class << self
        def record_timestamps; false; end
      end
 
      save!
 
      class << self
        remove_method :record_timestamps
      end
    end
  end
end
