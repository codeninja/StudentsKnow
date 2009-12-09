# == Schema Information
# Schema version: 57
#
# Table name: invite_emails
#
#  id         :integer(11)     not null, primary key
#  email      :string(255)     
#  delivered  :boolean(1)      
#  valid      :boolean(1)      
#  invite_id  :integer(11)     
#  created_at :datetime        
#  updated_at :datetime        
#

class InviteEmail < ActiveRecord::Base
  belongs_to :invite
  validates_uniqueness_of :email, :scope => :invite_id
end
