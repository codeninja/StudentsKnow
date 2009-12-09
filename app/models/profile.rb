# == Schema Information
# Schema version: 57
#
# Table name: profiles
#
#  id              :integer(11)     not null, primary key
#  country         :string(255)     
#  state           :string(255)     
#  zip             :string(255)     
#  gender          :string(255)     
#  university      :string(255)     
#  dob             :datetime        
#  start           :datetime        
#  graduation      :datetime        
#  receive_emails  :boolean(1)      
#  email_sent      :boolean(1)      
#  over_13         :boolean(1)      
#  terms           :boolean(1)      
#  user_id         :integer(11)     
#  created_at      :datetime        
#  updated_at      :datetime        
#  classes         :text            
#  website         :string(255)     
#  city            :string(255)     
#  bio             :text            
#  paypal_email    :string(255)     
#  optin           :boolean(1)      default(TRUE)
#  grad_start      :date            
#  grad_grad       :date            
#  grad_university :string(255)     
#  fb_options      :text            
#

class Profile < ActiveRecord::Base
  require 'yaml'
  
  belongs_to :user
  # has_one :image
  
    acts_as_commentable
  
   validates_presence_of :country, :state, :zip, :gender, :dob, :university, :start, :graduation, :if => :is_tier_2?
   # validates_acceptance_of :privacy_policy ,:on => :create
    #attr_accessible :over_13
    
  validates_uniqueness_of :paypal_email, :if => :is_tier_2?
  
  validates_format_of :paypal_email,
    :with =>  %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i ,
    :message => "Invalid email format", :if => :is_tier_2?
  
  attr_accessor :up_tier
  attr_reader :tier
  
  def age
    ([(Time.now - dob).abs.to_i,1].max / 31536000).to_i
  rescue
    "N/A"
  end
  
  def is_birthday?
    return ((Date.today.month == dob.month) && (Date.today.day == dob.day)) if dob
  end
  
  def is_tier_2?
    return (((tier || 0) > 1) or (@up_tier ? (not @up_tier.empty?) : false))
  end
  
  def tier
    if user
      user.tier
    else
      1
    end
  end

  
  def tier=(tier_value)
    @tier = tier_value
    user.tier = tier_value if user
  end
  
  
  
  def set_fb_option!(option)
    options = YAML.load(fb_options || "--- {}\n\n")
    logger.info options
    options.merge!(option)
    self.fb_options = options.to_yaml
    logger.info fb_options
    save!
  rescue
    logger.warn "Invalid Facebook options. Resetting!"
    fb_options = "--- {}\n\n"
    save!
    return nil
  end
  
  def get_fb_option(key)
    options = YAML.load(fb_options || "--- {}\n\n")
    return options[key] ||= nil
  rescue
      logger.warn "Invalid Facebook options. Resetting!"
      fb_options = "--- {}\n\n"
      save
      return nil
  end

end
