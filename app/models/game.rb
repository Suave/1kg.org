class Game < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned
  Game::Version.belongs_to :user
  
  validates_presence_of :name, :level, :length, :size, :content, :category
  
  belongs_to :user
  
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "150x150>" }
  
  named_scope :category, lambda {|category| {:conditions => {:category => category}}}
  named_scope :limit,    lambda {|limit| {:limit => limit}}
  
  CATEGORIES = ['音乐课', '美工课（美术+手工）', '环境科普教育（环保+科普教育）', '语言类活动（普通话+英语课）', 
    '心理卫生健康课（卫生课+心理健康课）', '心灵教育（励志课+思想品德课）', '健身活动（体育课+广播体操）', '读书活动（阅读教育活动）',
    '法律安全知识（法律常识+安全自救培训）', '科技教育（电脑课）']
end