class VideosController < ApplicationController
  include ExceptionNotifiable
  include WhiteListHelper
  local_addresses.clear
  
  before_filter :login_required, :except => [:index, :show, :bad_record, :swf_create_asset, :swf_upload_complete, :search]
  
  layout 'home', :except => [:send_to_friend, :remote_comment_comment]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record
  
  # GET /videos
  # GET /videos.xml  
  def index
    opts = []
    category = Tag.find_by_name(params[:category])
    
    @categories = know_categories
    if category
      opts << category.name
      @category = category.name.gsub(/-/,'&nbsp;')
      @top_posters = User.top_posters(6,{:tags => category.name})
    else
      flash[:notice] = "There are no videos in the category: '#{params[:category]}'." if params[:category].is_a?(String)
      @category = "ALL VIDEOS"
      @top_posters = User.top_posters(6)
    end

    @page_title = "#{@category}"

    if params[:user_id]
      @user = User.find_by_id_or_login(params[:user_id])
      @videos = Video.find_with_tags(opts.compact,{:order => 'rating', :limit => 100, :paginate => true, :conditions => "videos.user_id = #{@user.id}"})
      @top_posters = [@user]
      @page_title = "#{@user.login}'s " + @page_title
      @rss_feed = "http://#{request.env['HTTP_HOST']}#{formatted_user_videos_path({:category => params[:category], :order => params[:order], :format => :rss, :user_id => params[:user_id]})}"
      @rss_feed_html = "<link rel='alternate' title='Top Videos Feed' href='http://#{@rss_feed}' type='application/rss+xml'>"
    else
      @user = nil
      @videos = Video.find_with_tags(opts.compact,{:order => 'rating', :limit => 5, :paginate => true})
      @rss_feed = "http://#{request.env["HTTP_HOST"]}#{formatted_videos_path({:category => params[:category], :order => params[:order], :format => :rss})}"
      @rss_feed_html = "<link rel='alternate' title='Top Videos Feed' href='http://#{@rss_feed}' type='application/rss+xml'>"
    end
    
#    ads = get_ads(:video, {:size => :block},2)
#    @right_ad_top = ads.first
#    @right_ad_bottom = ads.last
     @right_ad_top = Ad.page(:video).zone(:right_top).get.code
     @right_ad_bottom = Ad.page(:video).zone(:right_bottom).get.code
     
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @videos}
      format.rss { render :layout => false }
    end
  end


  # GET /videos/1
  # GET /videos/1.xml
  def show
    #for rating
    store_location    
    @video = Video.find(params[:id])
    
    if @video.is_flagged?
      redirect_to dirty_video_url 
      return
    end
    
    if @video.asset
      if @video.asset.status != 2
        flash[:notice] = "This Video is not yet ready to view.  Please try again in a few minutes to an hour."
        redirect_to home_path
      end
    else
      flash[:notice] = "This Video is not yet ready to view.  Please try again in a few minutes to an hour."
      redirect_to home_path
    end
    
    @user = self.current_user

    
    @video.referral_hit(params[:rc], (@user ? @user.id : nil))
  
    codes = video_codes(@video)
    @my_referral_code = codes[:my_referral_code]
    @share_url = codes[:share_url]
    @advert_loc = codes[:advert_loc]
    @swf_loc = codes[:swf_loc]
    @flashvars = codes[:flashvars]

    @page_title = @video.name
    @page_keywords = @video.name.gsub(" ", ", ")
    @page_description = @video.description

    respond_to do |format|      
      format.html do
        @related_videos = Video.find_with_tags(@video.tag_list, :limit => 5)
        @users = User.find(:all, :order => "created_at DESC").paginate(
              :per_page => User.admin_per_page,
              :page => params["page"] || 1)
        @comments = @video.comments.reverse.paginate(
              :per_page => 5,
              :page => params["page"] || 1)
        @rss_feed_html = "<link rel='alternate' title='Top Videos Feed' href='#{formatted_video_path(@video, :rss)}' type='application/rss+xml'>"
        # @page_title = 'Video: ' + @video.name
      end
      
      begin
#        ads = get_ads(:video, {:sub_id => @my_referral_code, :size => :block},2)
#        @right_ad_top = ads.first
#        @left_ad_bottom = ads.last
        @right_ad_top = Ad.page(:video).zone(:right_top).get(1, {:sub_id => @my_referral_code}).code
        @right_ad_bottom = Ad.page(:video).zone(:right_bottom).get(1, {:sub_id => @my_referral_code}).code
        hit(@right_ad_top, @my_referral_code)
        hit(@left_ad_bottom, @my_referral_code)
      rescue
      end
    
      format.js do
        render :partial => "videos/embed_video", :layout => false
      end
      
      format.xml  { render :xml => @video }
      format.rss { render :layout => false}
    end
  end

  # GET /videos/new
  # GET /videos/new.xml
  def new
    if self.current_user.profile.nil?
      store_location
      flash[:notice] = "Please create a profile before uploading."
      redirect_to new_profile_path(:up_tier => true)
      return
    else
      unless self.current_user.tier > 1
        store_location
        flash[:notice] = "Please provide a few more pieces of profile information before uploading."
        redirect_to edit_profile_path(self.current_user.profile.id, :up_tier => true)
        return
      end
    end
    @video = Video.new
    @asset = Videoasset.new
    @ticket_id = @video.create_ticket!(self.current_user)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @video }
    end
  end

  # GET /videos/1/edit
  def edit
    @video = self.current_user.videos.find(params[:id])
    @ticket_id = @video.create_ticket!(self.current_user)
    @page_title = "Editing #{@video.name}"
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Sorry, you cannot edit other users' videos."
      redirect_to(home_url)
  end
  

  
   def search
     @search_item = ((params[:video_search] ? params[:video_search][:item] : nil) || params[:search] || '')
     options = { :page => (params[:page] || 1), :limit => (params[:limit] || 5), :paginate => true }
     @videos = Video.search(@search_item, options)
     @users = User.search(@search_item)
   end
    

  # POST /videos
  # POST /videos.xml
  def create
    @video = self.current_user.videos.new(params[:video])
    respond_to do |format|
      if @video.save
        if params[:video][:upload_ticket]
          # data is coming from asynchronous swf upload form page
          @asset = @video.attach_uploaded_asset!(Videoasset)
          if @asset
            format.html { render :partial => "videos/video_info_form", :locals => {:all_done => true} }
          else
            format.html { render :partial => "videos/waiting_for_upload"}
          end
        else
          # all-in-one upload page
          flash[:notice] = 'Video was successfully created.'
          format.html {  redirect_to(video_path(@video)) }
          format.xml  { render :xml => @video, :status => :created, :location => @video }
        end
      else
        if params[:video][:upload_ticket]
          # data is coming from asynchronous swf upload form page
          format.html { render :partial => "videos/video_info_form"}
        else
          # all-in-one upload page
          format.html { render :action => "new" }
          format.xml  { render :xml => @video.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /videos/1
  # PUT /videos/1.xml
  def update
    @video = self.current_user.videos.find(params[:id])
    respond_to do |format|
      if @video.update_attributes(params[:video])
        if params[:video][:upload_ticket]
          # data is coming from asynchronous swf upload form page
          unless @video.asset
            @asset = @video.attach_uploaded_asset!(Videoasset) 
          else
            @asset = @video.asset
          end
          if @asset
            format.html { render :partial => "videos/video_info_form", :locals => {:all_done => true}}
          else
            format.html { render :partial => "videos/waiting_for_upload"}
          end
        else
          # all-in-one upload page
          flash[:notice] = 'Video was successfully updated.'
          format.html { redirect_to(@video) }
          format.xml  { head :ok }
        end
      else
          if params[:video][:upload_ticket]
            # data is coming from asynchronous swf upload form page
            format.html { render :partial => "videos/video_info_form"}          
          else
            # all-in-one upload page
            format.html { render :action => "edit" }
            format.xml  { render :xml => @video.errors, :status => :unprocessable_entity }
          end
        end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.xml
  def destroy
    @video = self.current_user.videos.find(params[:id])
    user = @video.user.dup
    @video.destroy

    respond_to do |format|
      format.html { redirect_to(user_path(user)) }
      format.xml  { head :ok }
    end
  end

  
  def swf_create_asset
    @asset = Videoasset.new(:uploaded_data => params[:videoasset], :upload_ticket => params[:upload_ticket])
    if @asset.save
      @video = @asset.attach_me_to!(Video)
      if @video
        render :nothing => true
      else
        render :nothing => true
      end
    else
      logger.info "Error saving video asset."
      render :nothing => true, :status => 500 
    end 
  end
  
  def swf_upload_complete
    @ticket_id = params[:upload_ticket]
    @video = Video.find_by_upload_ticket(@ticket_id)
    @asset = Videoasset.find_by_upload_ticket(@ticket_id)
    respond_to do |format|
      format.js
    end
  end
  
  def bad_record
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end
  
  def rate
    @video = Video.find(params[:id])
    @user = (logged_in? ? self.current_user : nil)
    @result = @video.rate(params[:rating].to_i, @user)
    @video.reload
    respond_to do |format|
      format.js
    end
    rescue
      render :nothing => true
  end
  
  def favorite
    @video = Video.find(params[:id])
    raise "invalid video id" unless @video
    @affinity = (params[:favorite].is_a?(String) ? (params[:favorite].downcase == "true" ? true : false ) : true )
    @result = (@affinity ? @video.is_liked_by!(self.current_user) : @video.is_not_liked_by!(self.current_user))
    if params[:redirect]
      redirect_to(user_path(self.current_user))
    else
      respond_to do |format|
        format.js
      end
    end
    rescue
      render :nothing => true
  end
  
  def remote_make_dirty
     v = Video.find(params[:id])
     v.flag!
  end
  
  def remote_save_video_comment
    @video = Video.find(params[:id], :include => :comments)
    unless params[:comment][:comment].gsub(/\s/,'').length < 1
      comment_text = white_list(params[:comment][:comment])
      @created_comment = Comment.new(:user_id => self.current_user.id, :comment => comment_text)
      @video.add_comment(@created_comment)
    end
    @comment = Comment.new()
  end
  
  def remote_comment_comment
    @comment = Comment.find(params[:id])
    unless params[:comment][:comment].gsub(/\s/,'').length < 1
      comment_text = white_list(params[:comment][:comment])
      @created_comment = Comment.new(:user_id => self.current_user.id, :comment => comment_text)
      @comment.add_comment(@created_comment)
    end
    respond_to do |format|
      format.js
    end
  end
  
  def remote_paginate
     @video = Video.find(params[:vid_id])
     page = params[:page].to_i || 1
      @comments = @video.comments.reverse.paginate(
             :per_page => Video.per_page,
             :page => params["page"] || 1)
   end
   
   def send_to_friend
     @video = Video.find(params[:id])
       if  ((params[:email][:email] || "").empty?) || ((params[:email][:message] || "").empty?)
         flash[:error] = "You must enter both an email and a message"
       else
             reg = Regexp.new(%r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i)
              if (!reg.match(params[:email][:email]).nil?)
                    begin
                        UserNotifier.deliver_send_message_to_friend(self.current_user, params[:email][:email], params[:email][:message], @video.id)
                         flash[:notice] = "Email sent"
                         @success = true
                         # redirect_to video_path(@video)
                    # rescue
                    #   flash[:error] = "There was"
                    end
              else
                  flash[:error] = "The provided email does not appear to be correct, please check and make any necessary changes."
              end #regexp
            
       end #params
     respond_to do |format|
       format.js
     end
  end
  

  
  def copy_embed_code
    @video = Video.find(params[:id])
    codes = video_codes(@video)
    @my_referral_code = codes[:my_referral_code]
    @share_url = codes[:share_url]
    @advert_loc = codes[:advert_loc]
    @swf_loc = codes[:swf_loc]
    @flashvars = codes[:flashvars]
  end

  def dirty
  end

  def confirm_delete
    @video = self.current_user.videos.find(params[:id])
  end


  private
  
  def is_dirty?
    @video = Video.find(params[:id])
    @video.is_dirty?
  end
  
  def video_codes(video)
    my_referral_code = video.referral_code((logged_in? ? self.current_user : nil))
    share_url = video_path(:id => video.id, :rc => my_referral_code)
    advert_loc = "http://#{HOSTNAME}/ads.xml?rc=#{my_referral_code}"
    swf_loc = "http://#{HOSTNAME}/flash/FLVPlayer.swf"
    flashvars = "videoURL=http://#{HOSTNAME}#{video.videoasset.public_filename()}&advertURL=#{advert_loc}"
    puts advert_loc
    return {
      :my_referral_code => my_referral_code,
      :share_url => share_url,
      :advert_loc => advert_loc,
      :swf_loc => swf_loc,
      :flashvars => flashvars
    }
  end

end
