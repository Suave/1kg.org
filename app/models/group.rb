# == Schema Information
#
# Table name: groups
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  geo_id     :integer(4)      not null
#  title      :string(255)     not null
#  body_html  :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#  avatar     :string(255)
#  slug       :string(255)
#

class Group < ActiveRecord::Base
  include BodyFormat
  
  file_column :avatar, :magick => {
                              :geometry => "72x72>",
                              :versions => {"small" => "16x16", "medium" => "32x32", "large" => "48x48"}
                            }
  
  belongs_to :city,    :class_name => "Geo",  :foreign_key => "geo_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"
  
  has_many :memberships, :dependent => :destroy
  has_many :members,     :through => :memberships, :source => :user
  
  has_many :topics, :as => 'boardable', :dependent => :destroy
  
  before_save  :format_content
  after_create :init_membership
  after_create :create_feed
  
  validates_presence_of :title, :message => "请填写小组名",:within => 1..20
  validates_presence_of :geo_id, :message => "请选择小组所在城市"
  
  acts_as_manageable

  def name 
    title
  end

  define_index do
    # fields
    indexes title
    indexes body_html, :as => :description
  end
  
  def joined?(user)
    user.class == User && members.include?(user)
  end

  class << self
    def most_members
      find(:all).sort!{ |x,y| y.memberships.count <=> x.memberships.count }[0...8]
    end
  end
  
  private
  def create_discussion
    self.members << self.creator
    self.managers << self.creator
  end
  
  def format_content
    self.body_html = sanitize(self.body_html)
  end
  
  def create_feed
    self.creator.feed_items.create(:user_id => self.creator.id, :category => 'create_group',
                :item_id => self.id, :item_type => 'Group') if self.creator
  end
end
