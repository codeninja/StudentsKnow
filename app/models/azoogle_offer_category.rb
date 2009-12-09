# == Schema Information
# Schema version: 57
#
# Table name: azoogle_offer_categories
#
#  id   :integer(11)     not null, primary key
#  name :string(255)     
#

class AzoogleOfferCategory < ActiveRecord::Base
  has_and_belongs_to_many :offers, :class_name => "AzoogleOffer", :join_table => "azoogle_offers_categories", :foreign_key => 'category_id'
end
