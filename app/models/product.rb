# == Schema Information
#
# Table name: products
#
#  id            :integer(4)      not null, primary key
#  vendor_id     :integer(4)
#  stuff_type_id :integer(4)
#  title         :string(255)
#  serial        :string(255)
#  return_url    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Product < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :stuff_type
end
