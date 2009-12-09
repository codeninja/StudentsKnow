# == Schema Information
# Schema version: 57
#
# Table name: azoogle_accounts
#
#  id         :integer(11)     not null, primary key
#  login_hash :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class AzoogleAccount < ActiveRecord::Base  
  has_many :offers, :class_name => "AzoogleOffer", :dependent => :destroy
  
  
end
