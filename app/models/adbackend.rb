# == Schema Information
# Schema version: 57
#
# Table name: adbackends
#
#  id   :integer(11)     not null, primary key
#  name :string(255)     
#

class Adbackend < ActiveRecord::Base
  has_many :ads, :dependent => :destroy
  validates_presence_of :name
  validates_uniqueness_of :name
end
