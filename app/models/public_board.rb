# == Schema Information
#
# Table name: public_boards
#
#  id               :integer(4)      not null, primary key
#  title            :string(100)     not null
#  description      :text
#  description_html :text
#  position         :integer(4)      default(999), not null
#  slug             :string(255)
#  deleted_at       :datetime
#

class PublicBoard < ActiveRecord::Base
  include BodyFormat
  
  has_many :topics, :as => 'boardable', :dependent => :destroy
  
  acts_as_paranoid
  acts_as_manageable
  
  before_save :format_content
  
  def board_id
    board.id
  end
  
  private
  def format_content
    self.description_html = sanitize(description||'')
  end
end
