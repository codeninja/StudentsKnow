module Rffmpeg
  
  raise LoadError.new if `ffmpeg`.empty?

  class VideoFile
    require 'open3'
    attr_reader :input, :output, :duration, :audio_format, :video_format, :dimensions, :ffmpeg_info
    
    def initialize(filename)
      # @file = File.open(filename)
      raise "Input file does not exist => #{filename}" unless File.exist?(filename)
      @filename = filename
      get_info!
      # raise "Invalid Input: => #{@filename}\n#{@ffmpeg_info}" unless valid_input?
    end
    
    def get_info
      info_re = /Duration: ([0-9][0-9]:[0-9][0-9]:[0-9][0-9]).+Audio: ([^,]+),.+Video: ([^,]+),.+?([0-9]+x[0-9]+) /m
      duration_re = /Duration: ([0-9][0-9]:[0-9][0-9]:[0-9][0-9])/m
      audio_re = /Audio: ([^,]+),/m
      video_re = /Video: ([^,]+),/m
      dimensions_re = /Video: [^,]+,.+?([0-9]+x[0-9]+)/m
      stdin, stdout, stderr = Open3.popen3("ffmpeg -i #{@filename}")

      output = stderr.read
      raise "Invalid input file: #{output}" if $? != 0
      
      @ffmpeg_info = info = output.match(info_re)
      
      dm = output.match(duration_re)
      am = output.match(audio_re)
      vm = output.match(video_re)
      dmm = output.match(dimensions_re)
      
      @duration = dm[1] if dm
      @audio = am[1] if am
      @video = vm[1] if vm
      @dimensions = dmm[1] if dm
      
      info = {
        :duration => @duration,
        :audio_format => @audio,
        :video_format => @video,
        :dimensions => @dimensions
      }
      
      return info
    end

    def convert!(opts)
      raise "No input" unless @filename
      raise "Specify output file!" unless opts[:output].is_a?(String)
      raise "Output file exists!: #{opts[:output].inspect}" if File.exist?(opts[:output])
      raise "Invalid output size" unless opts[:size].match(/^[0-9]+x[0-9]+$/)
      default_options = {:ar => "22050", :ab => "56k", :size => "320x240"}
      options = default_options.merge(opts).merge( :input => @filename)
      cmdline = build_commandline(options)
      # puts "Converting #{@filename} => #{opts[:output]}"
      # puts cmdline
      stdin, stdout, stderr = Open3.popen3(cmdline)
      error_text = stderr.read
      if $? == 0
        # @input = File.open(@filename,"r") 
        # @output = File.open(opts[:output],"r")
        return true
      else
        raise "Error in conversion: #{error_text}"
      end
    end
    
    def grab_frame(time,output_path)
      raise "Time must be an integer in seconds" unless time.is_a?(Fixnum)
      raise "Invalid output path" unless File.exist?(output_path)
      time = (@duration.to_f / 2) if time > @duration.to_f
      output_filename = output_path + "/movie-grab#{rand(10000)}"
      cmdline = "nice -n 15 ffmpeg -i #{@filename} -an -ss #{seconds_to_time(time)} -t 00:00:01 -r 1 -y -s #{@dimensions} #{output_filename}%d.jpg"
      stdin, stdout, stderr = Open3.popen3(cmdline)
      error_text = stderr.read
      if $? == 0
        system("rm #{output_filename}2.jpg") if File.exist?("#{output_filename}2.jpg")
        return (output_filename + "1.jpg")
      else
        raise "Error in conversion: #{error_text}"
      end
    end
    
    private
    
    def get_info!
      get_info.to_a.each do |i|
        if self.respond_to?(i[0].to_s)
          instance_variable_set("@" + i[0].to_s,i[1])
        end
      end
    end  
    
    def valid_input?
      @dimensions && @video_format && @audio_format && @duration
    end
    
    def build_commandline(options)
      "ffmpeg -i #{options[:input]} #{"-an " if unknown_audio?} -ar #{options[:ar].to_s} -ab #{options[:ab].to_s} -f flv -s #{options[:size]} #{options[:output]}"
    end
    
    # def cropping_options(input_dim,output_dim)
    #   return "" if input_dim == output_dim
    #   inx = input_dim.match(/([0-9]+)x/)[1].to_f
    #   iny = input_dim.match(/x([0-9]+)/)[1].to_f
    #   outx = output_dim.match(/([0-9]+)x/)[1].to_f
    #   outy = output_dim.match(/x([0-9]+)/)[1].to_f
    #   in_aspect = inx / iny
    #   out_aspect = outx / outy
    #   if in_aspect > out_aspect
    #     x_over = inx - (iny / out_aspect)
    #     outx1 = x_over / 2
    #     outy1 = 0
    #     outx2 = outx1 + (iny / out_aspect)
    #     outy2 = iny
    #   elsif in_aspect < out_aspect
    #     y_over = iny - (inx / out_aspect)
    #     outx1 = 0
    #     outy1 = y_over / 2
    #     outx2 = inx   
    #     outy2 = outy1 + (inx / out_aspect)
    #   end
    # end
    
    def seconds_to_time(seconds)
      out = ""
      time = seconds.to_i
      out += sprintf("%02d:",(time / 3600).to_i)
      time = time - (((time / 3600).to_i) * 3600)
      out += sprintf("%02d:",(time / 60).to_i)
      time = time - (((time / 60).to_i) * 60)
      out += sprintf("%02d:",time)
      out
    end
    
    def unknown_audio?
      isbad = @audio.match(/^0x[0-9]{4}/)
      if isbad
        raise "Invalid Audio format => #{@audio}\n#{@ffmpeg_info}"
      end
      isbad
    rescue
      true
    end
    
  end
end
