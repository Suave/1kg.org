class GoodPhoto < ActiveRecord::Base
  belongs_to :good
  
  # must be 300x300px 
  has_attachment :processor => :rmagick,
                 :content_type => :image,
                 :storage => :file_system,
                 :max_size => 2.megabytes
                 
  validates_as_attachment
end