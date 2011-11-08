class Photo < ActiveRecord::Base
  belongs_to :photoable,:polymorphic => true
  belongs_to :user
  
  acts_as_ownable
  acts_as_voteable
  
  has_attached_file :image, :styles => {:'107x80' => ["107x80#"],:'max240x180' => ["240x180>"],:max565x420 => ["565x420>"]},
                            :url=>"/media/photos/:id/:attachment/:style.:extension",
                            :default_style=> :'107x80',
                            :default_url=>"/defaults/photos/:attachment/:style.png"
  
  attr_accessible :image, :title, :description, :description_html,:photoable_type,:photoable_id
  
  before_save :fill_title, :format_content
  
  named_scope :with_activity, :conditions => {:photoable_type => 'Activity'}
  named_scope :with_school, :conditions => {:photoable_type => 'School'}
  named_scope :include, lambda {|includes| {:include => includes}}

  validates_presence_of :user_id
  validates_presence_of :image_file_name
  
  def self.recent
    find(:all, :conditions => "parent_id is NULL", :order => "updated_at desc", :limit => 8)
  end
  
  def previous(user)
    Photo.find(:first, :conditions => ["parent_id is NULL and id < ? and user_id = ?", self.id, user.id], :order => "id DESC")
  end
  
  def next(user)
    Photo.find(:first, :conditions => ["parent_id is NULL and id > ? and user_id = ?", self.id, user.id])
  end
  
  def swf_uploaded_data=(data)
    data.content_type = MIME::Types.type_for(data.original_filename)
    self.uploaded_data = data
  end
  
  private
  def fill_title
    self.title = "未命名图片" if self.title.blank?
  end
  
  def format_content
    self.description_html = sanitize(description||'', true)
  end
  
  def create_feed
    self.school.feed_items.create(:content => %(#{self.user.login} 在#{self.created_at.to_date}为#{self.school.title}上传了一张新照片：#{self.title}), :user_id => self.user.id, :category => 'photo',
                :item_id => self.id, :item_type => 'Photo') if self.school
  end
end
