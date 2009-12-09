# == Schema Information
# Schema version: 57
#
# Table name: knows
#
#  id            :integer(11)     not null, primary key
#  user_id       :integer(11)     
#  knowable_id   :integer(11)     
#  knowable_type :string(255)     
#  created_at    :datetime        
#  updated_at    :datetime        
#

class Know < ActiveRecord::Base
  acts_as_taggable
    
  belongs_to :user
  belongs_to :knowable, :polymorphic => :true
end
