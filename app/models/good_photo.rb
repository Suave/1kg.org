# == Schema Information
#
# Table name: good_photos
#
#  id           :integer(4)      not null, primary key
#  parent_id    :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  thumbnail    :string(255)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  good_id      :integer(4)
#

class GoodPhoto < ActiveRecord::Base
  belongs_to :good
  
  # must be 300x300px 
  has_attachment :processor => :rmagick,
                 :content_type => :image,
                 :storage => :file_system,
                 :max_size => 2.megabytes
                 
  validates_as_attachment
end
