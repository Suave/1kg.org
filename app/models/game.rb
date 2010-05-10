class Game < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned
  Game::Version.belongs_to :user

  validates_presence_of :name, :message => "请填写名称"
  validates_presence_of :level, :message => "请选择适合年级"
  validates_presence_of :length, :message => "请选择时间长度"
  validates_presence_of :size, :message => "清选择适合人数"
  validates_presence_of :content, :message => "请填写内容"
  
  belongs_to :game_category
  belongs_to :user
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_attached_file :photo, :styles => { :game_image => "164x164>", :game_avatar => "128x128>" }
  has_many :references
  accepts_nested_attributes_for :references, :allow_destroy => true
  
  named_scope :category, lambda {|category| {:conditions => {:category => category}}}
  named_scope :limit,    lambda {|limit| {:limit => limit}}
  

  def clean_html
    self.content
  end
end