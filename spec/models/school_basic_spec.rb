# == Schema Information
# Schema version: 20090430155946
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  avatar                    :string(255)
#  geo_id                    :integer(4)
#  old_id                    :integer(4)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe SchoolBasic do
  it "should parse address to coordinates before create a new school"
end
