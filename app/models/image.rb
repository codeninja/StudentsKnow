# == Schema Information
# Schema version: 57
#
# Table name: images
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  description :string(255)     
#  profile_pic :boolean(1)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Image < ActiveRecord::Base
  
  acts_as_taggable
  acts_as_commentable
  
  has_one :imageasset, :as => :attachable, :dependent => :destroy
  belongs_to :user
  
  validates_presence_of :fileupload, :on => :create

  attr_reader :fileupload

  def fileupload=(thedata)
    @fileupload = thedata
    errors.add_to_base("Invalid upload") unless Asset.is_valid_file?(thedata)
    if new_record?
      create_imageasset(:uploaded_data => thedata)
    else
      if imageasset
        imageasset.update_attributes(:uploaded_data => thedata)
      else
        create_imageasset(:uploaded_data => thedata)
      end
    end
  end
  
  def public_filename(*args)
    imageasset.public_filename(*args)
  end
  

  
end
