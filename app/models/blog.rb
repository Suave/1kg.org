# == Schema Information
#
# Table name: blogs
#

class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => 'commentable', :dependent => :destroy
  validates_presence_of :title, :message => "请填写标题"
  validates_presence_of :title, :message => "请填写分类"
attr_accessible :title, :body_html,:category, :user_id
end
