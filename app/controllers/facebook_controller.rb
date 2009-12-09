class FacebookController < ApplicationController
  ensure_authenticated_to_facebook
  # ensure_application_is_installed_by_facebook_user
  
  before_filter :get_fb_user, :except => [:uninstall]
  before_filter :login_via_facebook_uid, :except => [:signup, :do_signup, :do_login, :uninstall]
  # before_filter :need_login, :except => [:signup, :do_signup, :do_login]
  
  def index
    # get_fb_user
    # login_via_facebook_uid
    store_location
    @active_tab = "about"
  rescue
    uninstall
  end
  
  def browse
    # get_fb_user
    # login_via_facebook_uid
    store_location
    @active_tab = "browse"
    @category = (Tag.find_by_name(params[:category]).name rescue nil) if params[:category]
    @knows = Video.find_with_tags([@category].compact, {:order => 'date', :limit => 5, :paginate => true})
  end
  
  def video
    @video = Video.find(params[:id])
    
    if @video.is_flagged?
      flash[:notice] = "This Video has been flagged as inappropriate."
      @bad_video = true
      return
    end
    
    if @video.asset
      if @video.asset.status != 2
        flash[:notice] = "This Video is not yet ready to view.  Please try again in a few minutes to an hour."
        @bad_video = true
      end
    else
      flash[:notice] = "This Video is not yet ready to view.  Please try again in a few minutes to an hour."
      @bad_video = true
    end
    
    codes = video_codes(@video)
    @my_referral_code = codes[:my_referral_code]
    @share_url = codes[:share_url]
    @advert_loc = codes[:advert_loc]
    @swf_loc = codes[:swf_loc]
    @flashvars = codes[:flashvars]
    
  end
  
  
  def account
    get_fb_user
    login_via_facebook_uid
    @active_tab = "account"
  end
  
  
  def my_videos
    get_fb_user
    login_via_facebook_uid
    store_location
    @active_tab = "my_videos"
  end
  
  def feeds
    get_fb_user
    login_via_facebook_uid
    @active_tab = 'feeds'
    @know_feed = KnowFeed.new
    if params[:feed_id]
      @active_feed = KnowFeed.find(params[:feed_id])
    else
      @active_feed = @user.know_feeds.first unless params[:new]
    end
  end
  
  def create_feed
    get_fb_user
    login_via_facebook_uid
    return unless request.post?
    if (params[:know_feed][:name] || '').empty?
      flash[:error] = "Please provide a name for your feed."
      redirect_to :action => :feeds, :new => true
    end
    @know_feed = @user.know_feeds.create(:name => params[:know_feed][:name])
    if @know_feed
      params[:category].each_pair do |key,value|
        if value.to_i == 1
          tag = Tag.find(key.to_i)
         @know_feed.tag_list.add tag.name if tag
        end
      end
      @know_feed.save
      @know_feed.filters = params[:know_feed][:filters]
      @know_feed.save
      redirect_to :action => :feeds, :feed_id => @know_feed.id
    else
      redirect_to :action => :feeds, :new => true
    end
  end
  
  def edit_feed
    get_fb_user
    login_via_facebook_uid
    @active_tab = 'feeds'
    @know_feed = KnowFeed.find(params[:id])    
    if request.post?
      @know_feed.name = params[:know_feed][:name]
      @know_feed.tag_list = nil
      @know_feed.save
      params[:category].each_pair do |key,value|
        if value.to_i == 1
          tag = Tag.find(key.to_i)
          @know_feed.tag_list.add tag.name if tag
        end
      end
      @know_feed.save
      @know_feed.filters = params[:know_feed][:filters]
      @know_feed.save
      redirect_to :action => :feeds, :feed_id => @know_feed.id
    end
  end
  
  def remove_feed
    get_fb_user
    login_via_facebook_uid
    KnowFeed.destroy(params[:id])# if request.post?
    redirect_to :action => :feeds
  end
  
  def about
    # get_fb_user
    # login_via_facebook_uid
    get_fb_user
    login_via_facebook_uid
    @active_tab = 'about'
  end
  
  def favorites
    get_fb_user
    login_via_facebook_uid
    store_location
    @active_tab = "my_videos"
    @category = (params[:select] == 'marked' ? 'marked' : ((tag = Tag.find_by_name(params[:select])).nil? ? 'marked' : tag.name))
  end
  
  def mark_favorite
    get_fb_user
    login_via_facebook_uid
    @video = Video.find(params[:id])
    if @video
      @video.is_liked_by!(@user)
      @video.reload
      FacebookPublisher.deliver_profile_for_user(@fb_user)
      respond_to do |format|
        format.js
      end
    else
      render :nothing => true
    end
  end
  
  def un_favorite
    get_fb_user
    login_via_facebook_uid
    @remove = true if params[:remove] == 'yes'
    @video = Video.find(params[:id])
    if @video
      @video.is_not_liked_by!(@user)
      respond_to do |format|
        format.js
      end
    else
      render :nothing => true
    end
  end
  
  def favorite_category
    get_fb_user
    login_via_facebook_uid
    @category = Tag.find(params[:id])
    if params[:new_value] == 'true'
      @category.is_liked_by!(@user)
    else
      @category.is_not_liked_by!(@user)
      @do_remove = true unless @category.is_category
    end
    @category.reload
    respond_to do |format|
      format.js
    end
  end
  
  def category_search
    get_fb_user
    login_via_facebook_uid
    # login_via_facebook_uid
    @add_id = params[:add_id]
    begin
      @category = Tag.find_by_name(params[:search_category][:search].downcase)
    rescue
      @category = nil
    end
    respond_to do |format|
      format.js
    end
  end
  
  def invite_friends
    @active_tab = 'invite'
    render :layout => false
  end
  
  def signup
    @user = User.new
  end
  
  def do_signup
    get_fb_user
    # cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.fbid = @fb_uid
    unless @user.save!
      render :action => :signup and return
    else
      @user.activate
      login_via_facebook_uid
      FacebookPublisher.deliver_profile_for_user(@fb_user)
      redirect_to :action => :index
    end
    rescue ActiveRecord::RecordInvalid
      render :action => :signup
  end
  
  def do_login
    get_fb_user
    if @user = User.authenticate(params[:user][:login], params[:user][:password])
      @user.fbid = @fb_uid
      @user.save
      login_via_facebook_uid
      FacebookPublisher.deliver_profile_for_user(@fb_user)
      redirect_to :action => :index
    else
      @user = User.new
      flash[:login_error] = "Incorrect username or password."
      render :action => :signup
    end
    rescue
      flash[:login_error] = "This account needs to be activated. Check your email, activate, and try again."
      render :action => :signup
  end
  
  def paginate_section
    get_fb_user
    login_via_facebook_uid
    @options = { :page => (params[:page] || 1), 
                :order => (params[:order] || "date"),
                :limit => (params[:limit] || 5 ),
                :paginate => true
              }
               
    tags = (params[:tags] || "").split(',')
    know_klass = Kernel.const_get((params[:know_class] || "video").capitalize)
    
    @order = @options[:order]
    @default_order = params[:default_order] || 'date'
    @section_id = (params[:section_id] || "new_knows_list")
    
    if params[:search_string]
      @knows = know_klass.search(params[:search_string],@options)
    else
      @knows = know_klass.find_with_tags(tags,@options)
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def set_options
    get_fb_user
    login_via_facebook_uid
    @user.profile.set_fb_option!(:profile_feed => params[:profile_feed].to_s )
    @user.reload
    FacebookPublisher.deliver_profile_for_user(@fb_user)
    flash[:status] = "Your Profile was updated."
    redirect_to :action => :account
  end
  
  def uninstall
    login_via_facebook_uid
    session[:facebook_session] = nil
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to :action => :index
  end

  private

  
  def video_codes(video)
    my_referral_code = video.referral_code((logged_in? ? self.current_user : nil))
    share_url = video_path(:id => video.id, :rc => my_referral_code)
    advert_loc = "http://#{HOSTNAME}/ads.xml?rc=#{my_referral_code}"
    swf_loc = "http://#{HOSTNAME}/flash/FLVPlayer.swf"
    flashvars = "videoURL=http://#{HOSTNAME}#{video.videoasset.public_filename()}&advertURL=#{advert_loc}"
    
    return {
      :my_referral_code => my_referral_code,
      :share_url => share_url,
      :advert_loc => advert_loc,
      :swf_loc => swf_loc,
      :flashvars => flashvars
    }
  end

  def login_via_facebook_uid
    unless logged_in?
      @user = User.authenticate(nil, nil, @fb_uid)
      if @user.is_a?(User)
        self.current_user = @user
        logger.info "Logged in as StudentsKnow.com User from Facebook UID #{@fb_uid} => #{@user.login}" if @user
        return true
      else
        logger.info "Facebook UID #{@fb_uid} has no user"
        redirect_to :action => :signup and return true
      end
    else
      logger.info "Logged in as StudentsKnow.com User from Facebook UID #{@fb_uid} => #{@user.login}" if @user
      @user = self.current_user
      @user.reload
      return true
    end
  end

  def need_login
    (redirect_to :action => :signup and return) unless logged_in?
  end
  
  def get_fb_user
    @fb_session = session[:facebook_session].clone
    @fb_uid = @fb_session.user.uid
    @fb_user = @fb_session.user
    logger.info "Logged in as Facebook UID => #{@fb_uid}"
    true
  end
  
end
