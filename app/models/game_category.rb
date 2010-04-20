class GameCategory < ActiveRecord::Base
  has_many :games
  has_attached_file :photo, :styles => { :thumb => "150x150>" }
  validates_presence_of :name, :message => "请填写名称"
  validates_presence_of :slug, :message => "请填写路径"
end
