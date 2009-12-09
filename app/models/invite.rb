# == Schema Information
# Schema version: 57
#
# Table name: invites
#
#  id         :integer(11)     not null, primary key
#  first_name :string(255)     
#  last_name  :string(255)     
#  email      :string(255)     
#  friends    :string(255)     
#  message    :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Invite < ActiveRecord::Base
  VALID_EMAIL_REGEX = Regexp.new(%r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i)
  
  validates_uniqueness_of :email
  has_many :invite_emails
  
  validates_presence_of :first_name, :email, :message
  validates_presence_of :friends, :on => :create
  
  validates_format_of :email, :with => VALID_EMAIL_REGEX
  
  attr_accessor :friends
  
  
  def validate
    validate_friends_emails
  end
  
  def valid_friends
    raw_friends.select{|f| f.match(VALID_EMAIL_REGEX)}
  end
  
  def raw_friends
    friends.split(/ ,/)
  end
  
  private
  
  def validate_friends_emails
    if raw_friends.size != valid_friends.size
      (raw_friends - valid_friends).each do |f|
        errors.add "friends", " => #{f} is an invalid email address."
      end
    end
  end
  
end
