class Visited < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  def Visited.status(status)
    case status
    when 'visited': 1
    when 'interesting': 2
    end
  end
end