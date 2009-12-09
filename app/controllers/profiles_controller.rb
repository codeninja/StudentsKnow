class ProfilesController < ApplicationController
  include ExceptionNotifiable
  local_addresses.clear
  
  layout "home"
  
   before_filter :login_required
  
  def index
    redirect_to users_path
  end
  
  def show
    redirect_to user_path(self.current_user.login)
  end
  
  
  def new
    @profile = Profile.new
    @profile.user = self.current_user
    if params[:up_tier]
      @show_tier2_fields = true
      @profile.up_tier = true
    end
  end
  
  def edit
    @profile = self.current_user.profile
    if params[:up_tier]
      @show_tier2_fields = true
      @profile.up_tier = true
    end
  end
  
  
  def save
    @profile = Profile.new(params[:profile])
    @profile.user = self.current_user

    profile_pic = Image.new(params[:image]) if params[:image]
    profile_pic.profile_pic = true
    
    @profile.user.images << profile_pic

    if @profile.save
      @profile.user.tier = 2 if @profile.up_tier
       self.current_user.reload
       redirect_back_or_default(user_path(self.current_user))
    else
      @show_tier2_fields = @profile.up_tier
      render :action => :new
    end
  end
  
  def update
    @profile = self.current_user.profile

    if params[:image]
      if @profile.user.profile_pic
        @profile.user.profile_pic.update_attributes(params[:image])
      else
        profile_pic = Image.new(params[:image]) if params[:image]
        profile_pic.profile_pic = true
        @profile.user.images << profile_pic
      end
    end

    if @profile.update_attributes(params[:profile])
        self.current_user.tier = @profile.tier
        self.current_user.save
        self.current_user.reload
       redirect_to :action => :show
    else
      @show_tier2_fields = @profile.up_tier
      render :action => :edit
    end
  end
  
   
  def crop_image
    @profile = self.current_user.profile
  end
  
  def save_crop
    img = self.current_user.profile_pic.imageasset
    img.crop([[params[:crop][:x1],params[:crop][:y1]],[params[:crop][:x2],params[:crop][:y2]]])
    redirect_to :action => "show"
  end
  
  
  
  def save_crop1
    @profile = self.current_user.profile

    dims = params[:crop]
    require 'RMagick'
    base = Dir.getwd
    
    # attachment_fu names directories with 4 places, adding preceding 0's as needed
    folder =  sprintf("%04d", self.current_user.profile_pic.imageasset.id)
    
    #switch to using the 800x600 image
    tmpname = self.current_user.profile_pic.imageasset.filename
    newfile = tmpname.split(".")
    openfile = newfile[0] + "_large.jpg"
    #puts "opening reduced file " + openfile
     orig = Magick::Image.read(base + "/public/assets/0000/" +  folder + "/"  +  openfile).first
     # params for crop Image#crop(x, y, width, height)
     cropped = orig.crop(dims[:x1].to_i, dims[:y1].to_i, (dims[:width].to_i), (dims[:height].to_i ) )

    if (dims[:width].to_i == 400 && dims[:height].to_i == 300)
        #create the medium image (filename_medium.jpg
        tmpname = self.current_user.profile_pic.imageasset.filename
        newfile = tmpname.split(".")
        savefile = newfile[0] + "_medium.jpg"
        cropped.write(base + "/public/assets/0000/" + folder + "/"  + savefile )
    else
      #save to a tmp file
      
        tmpname = self.current_user.profile_pic.imageasset.filename
        newfile = tmpname.split(".")
        savefile = newfile[0] + "_temp_medium.jpg"
        cropped.write(base + "/public/assets/0000/" + folder + "/"  + savefile )
        #resize the file to 400 x 300
        med = Magick::Image.read(base + "/public/assets/0000/" + folder + "/"  + savefile).first
        cropped = med.crop_resized!(400, 300, Magick::NorthGravity)
        #save the new medium file
        tmpname = self.current_user.profile_pic.imageasset.filename
        newfile = tmpname.split(".")
        savefile = newfile[0] + "_medium.jpg"
        cropped.write(base + "/public/assets/0000/" + folder + "/"  + savefile )
    end
    
    
    #also make the thumb by reloading rhe cropped file and resizing it
    med = Magick::Image.read(base + "/public/assets/0000/" + folder + "/"  + savefile).first
    thumb_cropped = med.crop_resized!(100, 75, Magick::NorthGravity)
    thumbfile = newfile[0] + "_thumb.jpg"
    thumb_cropped.write(base + "/public/assets/0000/" + folder + "/"  + thumbfile )
    
    #these were used on the save_crop page to display the results
    @saved_pix = "/assets/0000/" + folder + "/"  + savefile
    @saved_thumb = "/assets/0000/" + folder + "/"  + thumbfile
    
    redirect_to :action => "show"
  end
  
  def image
      @image = self.current_user.profile_pic
  end
  
  def replace_crop
    @profile = self.current_user.profile
    if params[:image]
      if @profile.user.profile_pic
          @profile.user.profile_pic.update_attributes(params[:image])
      else
         profile_pic = Image.new(params[:image]) if params[:image]
         profile_pic.profile_pic = true
         @profile.user.images << profile_pic
      end
    end
  end
  
  def dashboard
      @vid_count = self.current_user.total_posts
      @week_views = self.current_user.total_views_this_week
      @month_views = self.current_user.total_views_this_month
      @total_views = self.current_user.total_views
      @view_rate = Rate.find(:first, :conditions => "rate_name='view'")
      @referral_rate = Rate.find(:first, :conditions => "rate_name='referral'")
  end
  
  def remote_profile_comments
      @profile = Profile.find(params[:id])
  end
  
  def remote_save_comment
    @profile = Profile.find(params[:id])
    @user = @profile.user
    @user_logged_in = self.current_user
    @comment = Comment.new(params[:comment])
    @comment.user_id = self.current_user.id
    @comment.commentable_type = "profile"
    if @profile.comments << @comment
      @saved = true
      @comments = @profile.comments.find(:all, :order => 'created_at DESC')
      @comment = Comment.new()
    else 
      @saved = false
    end
     
  end
  
  def remote_delete_comment
    @comment = Comment.find(params[:id])
    @profile = Profile.find(@comment.commentable_id)
    @comment.destroy
    @comments = @profile.comments.reverse
    @user_logged_in = self.current_user
    @user = @profile.user
  end

end
