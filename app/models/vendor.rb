class Vendor < ActiveRecord::Base
  has_many :products
  
  validates_presence_of :slug, :message => "不能为空"
  validates_presence_of :title, :message => "不能为空"
  
  before_create :generate_signature_key
  
  private
  def generate_signature_key
    self.sign_key = Digest::SHA1.hexdigest("--#{self.slug}--#{Time.now.to_s}--")
  end
  
end