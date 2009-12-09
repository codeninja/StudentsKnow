# == Schema Information
# Schema version: 57
#
# Table name: azoogle_offers
#
#  id                 :integer(11)     not null, primary key
#  azoogle_account_id :integer(11)     
#  offer_id           :integer(11)     
#  title              :string(255)     
#  description        :string(255)     
#  notices            :string(255)     
#  open_date          :date            
#  expiry_date        :date            
#  amount             :integer(10)     
#  created_at         :datetime        
#  updated_at         :datetime        
#

class AzoogleOffer < ActiveRecord::Base
  belongs_to :azoogle_account
  has_many :creatives, :class_name => "AzoogleCreative", :dependent => :destroy
  has_and_belongs_to_many :categories, 
                          :class_name => "AzoogleOfferCategory", 
                          :join_table => "azoogle_offers_categories", 
                          :foreign_key => 'offer_id',
                          :association_foreign_key => 'category_id'
end
