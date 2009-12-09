# == Schema Information
# Schema version: 57
#
# Table name: admins
#
#  id                        :integer(11)     not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  name_first                :string(255)     
#  name_middle               :string(255)     
#  name_last                 :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  time_zone                 :string(255)     default("Etc/UTC")
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  activation_code           :string(40)      
#  activated_at              :datetime        
#  visits_count              :integer(11)     
#  last_login_at             :datetime        
#  password_reset_code       :string(40)      
#  password_reset_at         :datetime        
#

class Admin < ActiveRecord::Base
  include AuthenticatedBase
  
  validates_uniqueness_of :login, :email, :case_sensitive => false
  validates_presence_of :login, :email
  validates_confirmation_of :password, :email, :if => :password_required?
  
end
