# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_snapshots
#
#  id         :integer(4)      not null, primary key
#  school_id  :integer(4)
#  karma      :integer(4)
#  created_on :date
#

class SchoolSnapshot < ActiveRecord::Base
  belongs_to :school
end
