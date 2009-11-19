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

  BOOK_NEEDS = ['课外书', '低幼儿读物', '字典', '教辅', '报刊杂志']
  STATIONARY_NEEDS = ['笔', '美术用品', '橡皮', '文具盒', '书包', '本子', '卷笔刀']
  SPORT_NEEDS = ['篮球', '羽毛球', '乒乓球', '排球', '跳绳', '棋类', '益智类']
  CLOTH_NEEDS = ['棉衣', '校服', '鞋子', '袜子', '被子']
  ACCESSORY_NEEDS = ['三角板', '圆规', '直尺', '量角器', '粉笔', '录音机', '电脑', '音像制品', 'DVD机', '拼音卡片']
  COURSE_NEEDS = ['电脑课', '音乐课', '美术课', '环保课', '安全自救培训', '普通话', '卫生课', 
        '心理健康课', '英语课', '励志课', '体育课', '思想品德课', '科普教育课', '手工课', '眼保健操课', '阅读教育课', '法律常识']
  MEDICINE_NEEDS = ['感冒药', '发烧药', '腹泻药', '止血药', '止痛药']
  HARDWARE_NEEDS = %W(教学楼 宿舍楼 操场 篮球架 乒乓球桌 旗杆旗台 课桌椅 厕所 水池 垃圾池 窗户维修)
  TEACHER_NEEDS = %W(语文老师 数学老师 音乐老师 体育老师 美术老师 英语老师 计算机老师)
  
  def validate
    if book.blank? && stationary.blank? && sport.blank? && cloth.blank? && accessory.blank? && course.blank? && medicine.blank? && hardware.blank? && teacher.blank? &&  other.blank?
    errors.add_to_base("error")
  end
  end
  
  private
  def setup_tag
    tag_list = [self.urgency, self.book, self.stationary, self.sport, 
                      self.cloth, self.accessory, self.medicine, self.course, 
                      self.hardware, self.teacher, self.other].join(',').gsub(/,/, ' ')
    tag_list.gsub!(/,/, ' ')
    tag_list.gsub!(/，/, ' ')
    tag_list.gsub!(/、/, ' ')
    tag_list.gsub!(/。/, ' ')
    tag_list.gsub!(/：/, ' ')
    tag_list.gsub!(/；/, ' ')
    tag_list.gsub!(/□/, ' ')
    tag_list.gsub!(/√/, ' ')
    self.tag_list = tag_list
  end
end
