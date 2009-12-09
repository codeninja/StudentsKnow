# == Schema Information
# Schema version: 57
#
# Table name: adpages
#
#  id   :integer(11)     not null, primary key
#  name :string(255)     
#

class Adpage < ActiveRecord::Base
  require 'null_objs'
#  has_and_belongs_to_many :ads
  has_many :ad_zones, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def zone(zone_name)
    (ad_zones.find_by_name(zone_name.to_s) || NullZone.new)
  end
end
