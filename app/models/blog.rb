# == Schema Information
#
# Table name: blogs
#

class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => 'commentable', :dependent => :destroy
  validates_presence_of :title, :message => "请填写标题"
  validates_presence_of :title, :message => "请填写分类"
  
  def self.categories
    Blog.find(:all,:select => :category).map(&:category).uniq
  end
end
