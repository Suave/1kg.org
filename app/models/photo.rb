# == Schema Information
# Schema version: 20090430155946
#
# Table name: photos
#
#  id               :integer         not null, primary key
#  parent_id        :integer
#  content_type     :string(255)
#  filename         :string(255)
#  thumbnail        :string(255)
#  size             :integer
#  width            :integer
#  height           :integer
#  user_id          :integer
#  title            :string(255)     default(""), not null
#  description      :text
#  description_html :text
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#  activity_id      :integer
#  school_id        :integer
#

class Photo < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  belongs_to :school
  belongs_to :activity
  
  acts_as_paranoid
  
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
  
  attr_accessible :uploaded_data, :title, :description, :description_html, :school_id, :activity_id
  
  before_save :fill_title, :format_content
  
  named_scope :latest, :conditions => "photos.school_id is not null", :order => "updated_at desc", :limit => 12
  named_scope :include, lambda {|includes| {:include => includes}}
  
  def self.recent
    find(:all, :conditions => "parent_id is NULL", :order => "updated_at desc", :limit => 8)
  end
  
  def previous(user)
    Photo.find(:first, :conditions => ["parent_id is NULL and id < ? and user_id = ?", self.id, user.id], :order => "id DESC")
  end
  
  def next(user)
    Photo.find(:first, :conditions => ["parent_id is NULL and id > ? and user_id = ?", self.id, user.id])
  end
  
  def edited_by(user)
    user.class == User && (self.user_id == user.id || user.admin?)
  end
  
  
  private
  def fill_title
    self.title = "未命名图片" if self.title.blank?
  end
  
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
end
