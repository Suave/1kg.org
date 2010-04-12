class Game < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned
  Game::Version.belongs_to :user

  validates_presence_of :name, :message => "请填写名称"
  validates_presence_of :level, :message => "请选择适合年级"
  validates_presence_of :length, :message => "请选择时间长度"
  validates_presence_of :size, :message => "清选择适合人数"
  validates_presence_of :content, :message => "请填写内容"
  validates_presence_of :category, :message => "清选择分类"

  
  belongs_to :user
  
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "150x150>" }
end