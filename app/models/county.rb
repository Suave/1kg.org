class County < ActiveRecord::Base
  belongs_to :geo
  
  validates_presence_of :name
end