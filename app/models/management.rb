# -*- encoding : utf-8 -*-
class Management < ActiveRecord::Base
  belongs_to :manageable,:polymorphic => true
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => [:manageable_id,:manageable_type]
  scope :type_is,lambda {|manageable_type| {:conditions => {:manageable_type => manageable_type}}}
end
