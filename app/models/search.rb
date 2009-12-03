# == Schema Information
#
# Table name: searches
#
#  id         :integer(4)      not null, primary key
#  keywords   :string(255)
#  category   :string(255)     default("school")
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Search < ActiveRecord::Base
end
