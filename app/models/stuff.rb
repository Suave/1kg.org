class Stuff < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :type, :class_name => "StuffType", :foreign_key => :type_id
  belongs_to :buck, :class_name => "StuffBuck", :foreign_key => :buck_id
  belongs_to :user
  belongs_to :school
  
  before_save :format_content
  
  #validates_uniqueness_of :code, :message => "密码不能重复"
  def matched?
    matched_at.blank? ? false : true
  end
  
  private
  def format_content
    comment.strip! if comment.respond_to?(:strip!)
    self.comment_html = comment.blank? ? '' : formatting_body_html(comment)
  end
end