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

class Videoasset < Asset
  @content_type_string = "video"
  set_attachment_options   :processor => 'Rffmpeg',
                           :content_type => @content_type_string, 
                           :convert_video => { :defer => DEFER_CONVERSION, 
                                               :size => '400x300', 
                                               :format => 'flv', 
                                               :bitrate => '128k', 
                                               :thumbnails => {:thumb => '100x100', :screenshot => '400x300'}}

  belongs_to :video
  validates_presence_of :content_type, :filename
  
  def classname
    "Videoasset"
  end
  
end
