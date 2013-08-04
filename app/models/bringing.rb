# -*- encoding : utf-8 -*-
class Bringing < ActiveRecord::Base
  belongs_to :user
  belongs_to :box,       :counter_cache =>  true
  belongs_to :execution, :counter_cache =>  true

  validates_presence_of :box_id,:message => "必须选择盒子"
  validates_presence_of :number,:message => "必须选择数量"
end
