class Photo < ActiveRecord::Base
  belongs_to :user
  
  has_attachment :processor => :rmagick,
                 :content_type => :image,
                 :storage => :file_system,
                 :max_size => 2.megabytes,
                 :thumbnails => {
                   :square => "75x75!",
                   :thumb  => "120x80>",
                   :small  => "240x180>",
                   :medium => "565x420>"
                 }
  
  validates_as_attachment
  
  before_save :fill_title
  
  private
  def fill_title
    self.title = "未命名图片"
  end
  
end