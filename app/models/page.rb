# == Schema Information
# Schema version: 20090430155946
#
# Table name: pages
#
#  id                  :integer(4)      not null, primary key
#  title               :string(255)     not null
#  slug                :string(255)     not null
#  body                :text
#  created_at          :datetime
#  updated_at          :datetime
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#

class Page < ActiveRecord::Base
  validates_presence_of :title, :message => "请填上标题"
  validates_presence_of :slug,  :message => "请填上 slug"
  validates_uniqueness_of :slug, :message => "slug 必须是唯一的"
  
  belongs_to :last_modified_by, :class_name => "User", :foreign_key => "last_modified_by_id"
  
  def to_param
    slug
  end
  
  private
end
