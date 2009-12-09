require 'RMagick'
require 'rffmpeg'

module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module RffmpegProcessor
             
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end
           
        module ClassMethods
          
          def with_video(file,&block)
            begin
              v = Rffmpeg::VideoFile.new(file)  # should raise an error if invalid
              binary_data = file
            rescue
              logger.debug("Exception working with video: #{$!}")
              binary_data = nil
            end
            block.call binary_data if block && binary_data
          ensure
            !binary_data.nil?
          end
          
          def with_image(file, &block)
            begin
              binary_data = file.is_a?(Magick::Image) ? file : Magick::Image.read(file).first unless !Object.const_defined?(:Magick)
            rescue
              # Log the failure to load the image.  This should match ::Magick::ImageMagickError
              # but that would cause acts_as_attachment to require rmagick.
              logger.debug("Exception working with image: #{$!}")
              binary_data = nil
            end
            block.call binary_data if block && binary_data
          ensure
            !binary_data.nil?
          end
        end

        def recreate_video_thumbnails
          temp_path = full_filename
          v = Rffmpeg::VideoFile.new(temp_path)
          converted_movie_screenshot_name = v.grab_frame(3,"/tmp")
          # raise "File not found => #{converted_movie_screenshot_name}" unless File.exist?(converted_movie_screenshot_name)
          if File.exist?(converted_movie_screenshot_name)
            attachment_options[:convert_video][:thumbnails].each { |suffix, size| create_or_update_thumbnail_for_movie(converted_movie_screenshot_name, suffix, *size) }
            File.delete(converted_movie_screenshot_name)
          end
        end

      protected
        def process_attachment_with_processing
          return unless process_attachment_without_processing
          with_video do |vid|
            unless attachment_options[:convert_video][:defer] == true
              v = Rffmpeg::VideoFile.new(vid)
              attachment_options[:convert_video][:format] ||= 'flv'
              converted_movie_name = random_tempfile_filename + "." + attachment_options[:convert_video][:format]
              v.convert!({ :output => converted_movie_name, 
                           :size => (attachment_options[:convert_video][:size] || '400x300'), 
                           :format => (attachment_options[:convert_video][:format]),
                           :ab => (attachment_options[:convert_video][:bitrate] || '128k')})
              self.temp_path = write_to_temp_file(File.open(converted_movie_name,'r').read)
              self.filename = self.filename.sub(/\.\w+$/, ('.' + attachment_options[:convert_video][:format]) )
              self.length = v.duration
              File.delete(converted_movie_name)
              self.status = 2
              # raise "pointless error"
            else
              # mark as unconverted
              self.status = 0
            end
          end if video?
          
          with_image do |img|
            resize_image_or_thumbnail! img
            self.width  = img.columns if respond_to?(:width)
            self.height = img.rows    if respond_to?(:height)
            callback_with_args :after_resize, img
          end if image?
        end


        
        def create_video_thumbnails
          v = Rffmpeg::VideoFile.new(temp_path)
          converted_movie_screenshot_name = v.grab_frame(3,Technoweenie::AttachmentFu.tempfile_path)
          # raise "File not found => #{converted_movie_screenshot_name}" unless File.exist?(converted_movie_screenshot_name)
          if File.exist?(converted_movie_screenshot_name)
            attachment_options[:convert_video][:thumbnails].each { |suffix, size| create_or_update_thumbnail_for_movie(converted_movie_screenshot_name, suffix, *size) }
            File.delete(converted_movie_screenshot_name)
          end
        end
      
        # Performs the actual resizing operation for a thumbnail
        def resize_image(img, size)
          size = size.first if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
          if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
            size = [size, size] if size.is_a?(Fixnum)
            img.thumbnail!(*size)
          else
            img.change_geometry(size.to_s) { |cols, rows, image| image.resize!(cols, rows) }
          end
          self.temp_path = write_to_temp_file(img.to_blob)
        end
      end
    end
  end
end