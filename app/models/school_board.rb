# == Schema Information
#
# Table name: school_boards
#
#  id               :integer(4)      not null, primary key
#  school_id        :integer(4)      not null
#  description      :text
#  description_html :text
#  deleted_at       :datetime
#

# == Schema Information
#
# Table name: school_boards
#
#  id               :integer(4)      not null, primary key
#  school_id        :integer(4)      not null
#  description      :text
#  description_html :text
#  deleted_at       :datetime
#

class SchoolBoard < ActiveRecord::Base
  include BodyFormat
  
  has_one :board, :as => :talkable, :dependent => :destroy 
  belongs_to :school
  
  acts_as_paranoid
  
  before_save :format_content
  
  def board_id
    board.id
  end
  
  private
  def format_content
    self.description_html = sanitize(description||'')
  end
  
end
