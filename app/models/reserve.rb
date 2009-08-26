class Reserve < ActiveRecord::Base
  validates_presence_of :name, :message => "必填项"
  validates_presence_of :quantity, :message => "必填项"
  validates_format_of :quantity, :with => /^[1-9]+/
end