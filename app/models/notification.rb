# == Schema Information
# Schema version: 57
#
# Table name: notifications
#
#  id         :integer(11)     not null, primary key
#  uid        :integer(11)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Notification < ActiveRecord::Base
end
