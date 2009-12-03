# == Schema Information
#
# Table name: bulletins
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  body           :text
#  user_id        :integer(4)
#  created_at     :datetime
#  udpated_at     :datetime
#  redirect_url   :string(255)
#  comments_count :integer(4)      default(0)
#

class Bulletin < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  has_many :comments, :as => 'commentable', :dependent => :destroy
  
  validates_presence_of :title, :message => "不能为空"
  
  attr_accessible :title, :body, :redirect_url, :tag_list, :user_id
  
  named_scope :recent, :limit => 5, :order => 'id DESC'
end
