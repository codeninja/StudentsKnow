require 'digest/md5'

namespace :assets do
  namespace :videos do
    require 'rffmpeg'
    
    desc "Convert videos"
    task :convert => :environment do
      puts "DRY RUN!" if ENV["dry_run"] == "true"
      logger = Logger.new(File.open('log/convert.log', 'a'))
      
      logger.info "Starting Conversion (#{Time.now})"
      while (vid = Video.find(:first, :include => :videoasset, :conditions => 'assets.status = 0'))     
        # Set as queued
        logger.info " * Found uncoverted video #{vid.id}"
        vid.asset.status = 1
        vid.asset.save
        
        filename = vid.asset.full_filename
        converted_movie_name = random_tempfile_filename(vid.asset.attachment_options[:convert_video][:format])
        
        logger.info " * Converting #{filename} => #{converted_movie_name}..."
        convert_video(vid,filename, converted_movie_name)
        
        if ENV["dry_run"] == "true"      
          logger.info "  - Cleaning up..."
          FileUtils.rm(converted_movie_name)       
          vid.asset.status = 0
          vid.asset.save
        else
          logger.info "  - Replacing original with converted version."
          FileUtils.rm(filename)
          FileUtils.mv(converted_movie_name, filename)
          vid.asset.filename = vid.asset.filename.sub(/\.\w+$/, ('.' + vid.asset.attachment_options[:convert_video][:format]) )
          
          vid.asset.status = 2
          ActiveRecord::Base.connection.reconnect!
          vid.asset.save
        end

        logger.info "  - Done. (#{Time.now})"
      end
      logger.info "Finished Conversion. (#{Time.now})"
    end
    
  end
end



def random_tempfile_filename(format)
  return ("#{RAILS_ROOT}/tmp/#{Digest::MD5.hexdigest(Time.now.to_s).to_s}#{rand(10000)}." + format)
end


def convert_video(vid,filename, converted_movie_name)
  v = Rffmpeg::VideoFile.new(filename)
  v.convert!({ :output => converted_movie_name, 
               :size => (vid.asset.attachment_options[:convert_video][:size] || '400x300'), 
               :format => (vid.asset.attachment_options[:convert_video][:format]),
               :ab => (vid.asset.attachment_options[:convert_video][:bitrate] || '128k')})
  vid.asset.length = v.duration
end
