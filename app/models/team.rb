class Team < ActiveRecord::Base
  belongs_to :user  
  has_attached_file :image, :styles => { :team_icon => "32x32>",:team_logo => "160x160>"}
end
