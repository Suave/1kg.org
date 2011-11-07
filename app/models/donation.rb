# == Schema Information
#
# Table name: stuffs
#
#  id             :integer(4)      not null, primary key
#  code           :string(255)     not null
#  type_id        :integer(4)      not null
#  user_id        :integer(4)
#  school_id      :integer(4)
#  matched_at     :datetime
#  created_at     :datetime
#  comment_html   :text
#  comment        :text
#  auto_fill      :boolean(1)
#  buck_id        :integer(4)
#  order_id       :string(255)
#  product_number :string(255)
#  product_serial :string(255)
#  deal_id        :string(255)
#  order_time     :string(255)
#

require 'open-uri'

# 一个stuff对应用户的一次捐赠
class Donation < ActiveRecord::Base
  set_table_name 'stuffs'
  
  include 
  
  belongs_to :requirement_type, :foreign_key => :type_id
  belongs_to :requirement, :foreign_key => :buck_id
  belongs_to :user
  belongs_to :vendor
  belongs_to :school
  
  before_save :format_content
  
  named_scope :matched, :conditions => 'matched_at is NOT NULL'
  #validates_uniqueness_of :code, :message => "密码不能重复"
  
  def matched?
    matched_at.blank? ? false : true
  end
    
  # 通知积分商家，应该在后台执行
  def notify_vendor
    result = Onekg::RequestResult.new(self.return_url, self.order_time, self.order_id, self.id, self.created_at, 
                              '10', 'http://www.1kg.org/donations', self.vendor.sign_key)
    
    url = URI.parse(result.url)
    response = Net::HTTP.start(url.host, url.port) {|http|
      http.get("#{url.path}?#{result.params}&signMsg=#{result.sign_msg}")
    }
    result = JSON.parse(response.body)
    puts result
    self.update_attribute(:confirmed, result['result'].to_i == 1)
  end
  
  private
  def format_content
    self.comment_html = sanitize(comment||'')
  end
end
