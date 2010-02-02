# == Schema Information
#
# Table name: city_boards
#
#  id               :integer(4)      not null, primary key
#  geo_id           :integer(4)      not null
#  description      :text
#  description_html :text
#

# == Schema Information
#
# Table name: city_boards
#
#  id               :integer(4)      not null, primary key
#  geo_id           :integer(4)      not null
#  description      :text
#  description_html :text
#


class CityBoard < ActiveRecord::Base
  include BodyFormat
  
  has_one :board, :as => :talkable
  belongs_to :geo
  
  before_save :format_content
  
  
  def geo_name
    geo.name
  end
  
  def board_id
    board.id
  end
  
  
  private
  def format_content
    self.description_html = sanitize(self.description)
  end
end
