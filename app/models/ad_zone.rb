# == Schema Information
# Schema version: 57
#
# Table name: ad_zones
#
#  id         :integer(11)     not null, primary key
#  adpage_id  :integer(11)     
#  name       :string(255)     
#  size       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class AdZone < ActiveRecord::Base
  require 'null_objs'
  belongs_to :ad_page  
#  has_and_belongs_to_many :ads
  
  validates_presence_of :name, :size
  
  def self.available_sizes
    return Ad::SIZE_MAP.keys.collect{|s| s.to_s}
  end
  
  
  def possible_ads_by_backend
    Adbackend.find(:all, :include => :ads, :conditions => ["ads.size = ?", size])
  end
  
  def possible_ads
    Ad.find(:all, :conditions => ["size = ?", size])
  end
  
  def get(number=1, options={})
    out_ads = Ad.hack!(Ad.find(:all, :conditions => ["size = ?", size], :order => "RAND(#{rand(1000)})*weight desc", :limit => number), options)
    return (out_ads.size < 2 ? (out_ads.empty? ? NullAd.new : out_ads.first) : out_ads)
  end
  
end
