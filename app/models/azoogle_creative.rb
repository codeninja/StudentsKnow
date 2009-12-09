# == Schema Information
# Schema version: 57
#
# Table name: azoogle_creatives
#
#  id               :integer(11)     not null, primary key
#  azoogle_offer_id :integer(11)     
#  sub_id           :string(255)     
#  creative_type    :string(255)     
#  width            :integer(11)     
#  height           :integer(11)     
#  data             :text            
#  created_at       :datetime        
#  updated_at       :datetime        
#

class AzoogleCreative < ActiveRecord::Base
  belongs_to :offer, :class_name => 'AzoogleOffer', :foreign_key => 'azoogle_offer_id'
  
  def self.all_ads_for(referrer_code)
    self.find(:all, :conditions => ["sub_id = ?", referrer_code])
  end
end
