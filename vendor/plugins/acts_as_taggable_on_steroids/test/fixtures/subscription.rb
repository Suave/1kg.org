# -*- encoding : utf-8 -*-
class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :magazine
end
