# == Schema Information
#
# Table name: school_guides
#
#  id                  :integer(4)      not null, primary key
#  title               :string(255)
#  content             :text
#  user_id             :integer(4)
#  school_id           :integer(4)
#  hits                :integer(4)      default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  last_modified_by_id :integer(4)
#  last_modified_at    :datetime
#  last_replied_at     :datetime
#  comments_count      :integer(4)      default(0), not null
#  last_replied_by_id  :integer(4)
#  deleted_at          :datetime
#  clean_html          :text
#

class SchoolGuide < ActiveRecord::Base
  include BodyFormat
  include Editable
  
  belongs_to :school
  belongs_to :user
  has_many   :comments, :as => 'commentable', :dependent => :destroy
  
  acts_as_voteable
  acts_as_taggable
  acts_as_paranoid
  
  default_scope :order => 'last_replied_at DESC'
  
  validates_presence_of :title, :message => "不能为空"
  validates_length_of   :content, :minimum => 10, :too_short => "攻略内容不能少于10个字符", :allow_nil => false
  validates_presence_of :school_id, :message => "请选择您去的学校"
  validates_presence_of :user_id
  
  attr_accessible :title, :content, :tag_list, :school_id, :user_id, :last_replied_at, :last_replied_by_id, :comments_count
  
  before_save  :format_content
  after_create :initial_last_replied
  
  named_scope :recent, :limit => 5, :order => 'created_at DESC', :include => [:school, :tags, :user]
    
  def increase_hit_without_timestamping!
    self.hits += 1
    self.save_without_timestamping
  end
  
  def html
    self.clean_html ||= sanitize(self.content)
  end
  
  private
  def initial_last_replied
    self.update_attributes!(:last_replied_at => self.created_at, :last_replied_by_id => self.user_id)
  end
  
  def format_content
    self.clean_html = sanitize(self.content)
  end
end
