# == Schema Information
# Schema version: 57
#
# Table name: assets
#
#  id              :integer(11)     not null, primary key
#  parent_id       :integer(11)     
#  size            :integer(11)     
#  width           :integer(11)     
#  height          :integer(11)     
#  attachable_id   :integer(11)     
#  content_type    :string(255)     
#  filename        :string(255)     
#  thumbnail       :string(255)     
#  checksum        :string(255)     
#  attachable_type :string(255)     
#  is_duplicate    :boolean(1)      
#  created_at      :datetime        
#  updated_at      :datetime        
#  upload_ticket   :string(255)     
#  length          :string(255)     
#  status          :integer(11)     default(0)
#

class Asset < ActiveRecord::Base

  # require 'md5'

  # status codes:
  #  0 => uploaded, not convertd
  #  1 => being convertd
  #  2 => convertd
  #  3 => error converting

  @content_type_string = "image"
  DEFAULT_ATTACHMENT_OPTS = { :storage => :file_system, :path_prefix => 'public/assets'}
  
  has_attachment DEFAULT_ATTACHMENT_OPTS
  # validates_as_attachment
  
  belongs_to :attachable, :polymorphic => true
  validates_presence_of :filename
  

  def self.is_valid_file?(fileObj)
    if fileObj.is_a?(Tempfile) || fileObj.is_a?(StringIO) || (defined?(ActionController::TestUploadedFile) && fileObj.instance_of?(ActionController::TestUploadedFile))
      true
    else
      false
    end
  end
  
  def attach_me_to!(klass)
    if (p = klass.find_by_upload_ticket(upload_ticket))
      p.asset.destroy
      p.reload
      p.send("#{classname.downcase}=", self)
      return p
    else
      return nil
    end
  end

  
  private
  
  def self.set_attachment_options(options={})
    has_attachment DEFAULT_ATTACHMENT_OPTS.merge(options)
  end
  
end
