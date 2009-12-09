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

class Imageasset < Asset
  require 'RMagick'
  require 'fileutils'
  
  @content_type_string = "image"
 set_attachment_options :content_type => @content_type_string, :thumbnails => { :thumb => '80x60>', :medium => '400x300>' , :large => '700x700>'}
 #, :thumbnails => {:thumb => '100x100>', :medium => '400x300'}}
  
  belongs_to :image
  
  def before_save
    content_type = @content_type_string
  end
  
  

  def crop(coords)
    raise "invalid argument" unless coords.is_a?(Array) 
    x1 = coords[0][0].to_i
    x2 = coords[1][0].to_i
    y1 = coords[0][1].to_i
    y2 = coords[1][1].to_i
    new_width = x2 - x1
    new_height = y2 - y1
    temp_large = "#{RAILS_ROOT}/tmp/#{rand(1000000)}"
    large = full_filename(:large)
    File.cp(large,temp_large)
    orig = Magick::Image.read(large).first
    cropped = orig.crop(x1, y1, new_width, new_height)
    cropped.write(full_filename)
    save
    File.mv(temp_large,large)
  end
  
  
end
