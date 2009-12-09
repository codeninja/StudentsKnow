# == Schema Information
# Schema version: 57
#
# Table name: rates
#
#  id        :integer(11)     not null, primary key
#  rate_name :string(255)     
#  rate      :float           
#

class Rate < ActiveRecord::Base
  validates_presence_of :rate_name, :rate
  validates_uniqueness_of :rate_name
end
