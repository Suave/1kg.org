# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_needs
#
#  id                  :integer(4)      not null, primary key
#  school_id           :integer(4)
#  urgency             :string(255)
#  book                :string(255)
#  stationary          :string(255)
#  sport               :string(255)
#  cloth               :string(255)
#  accessory           :string(255)
#  course              :string(255)
#  teacher             :string(255)
#  other               :string(255)
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#

class SchoolNeed < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :school

  before_save :setup_tag

  BOOK_NEEDS = ['教辅书', '字典类', '课外读物', '科普', '作文', '卡通', '文学', '传记']
  STATIONARY_NEEDS = ['铅笔', '水性笔', '圆珠笔', '钢笔', '毛笔', '水彩笔', '橡皮', '文具盒', '书包', '本子', '语文本', '数学本', '英语本', '图画本', '田字本']
  SPORT_NEEDS = ['篮球', '排球', '足球', '羽毛球', '乒乓球', '跳绳', '象棋', '跳棋', '陆战棋', '五子棋', '益智类']
  CLOTH_NEEDS = ['棉衣', '运动服', '鞋子']
  ACCESSORY_NEEDS = ['直尺', '圆规', '三角板', '量角器', '地球仪', '拼音卡片', '英文字母卡片', '粉笔']
  COURSE_NEEDS = ['电脑课', '音乐课', '美术课', '环保课', '安全自救培训', '英语课', '普通话']
  TEACHER_NEEDS = ['语文老师', '数学老师', '英语老师', '音体美老师']
  
  private
  def setup_tag
    tag_list = [self.urgency, self.book, self.stationary, self.sport, 
                      self.cloth, self.accessory, self.course, self.teacher].join(',').gsub(/,/, ' ')
    tag_list.gsub!(/,/, ' ')
    tag_list.gsub!(/，/, ' ')
    tag_list.gsub!(/、/, ' ')
    tag_list.gsub!(/。/, ' ')
    tag_list.gsub!(/：/, ' ')
    tag_list.gsub!(/；/, ' ')
    tag_list.gsub!(/□/, ' ')
    self.tag_list = tag_list
  end
end
