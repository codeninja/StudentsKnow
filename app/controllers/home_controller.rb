class HomeController < ApplicationController
  include ExceptionNotifiable
  local_addresses.clear
  
  layout "home"
  
  def index
    # @new_knows = Video.find_with_tags([],{:paginate => true, :page => 1, :order => 'date'})
    @top_posters = User.top_posters(6)
    @knows = Video.find_with_tags([], {:order => 'date', :limit => 5, :paginate => true})
    
    # @page_title = "Home Page"
    @page_title = "Video and podcast tutorials on business, job hunting, arts, prep tests, literature, math and science."
    
    @rss_feed = home_feed_url(:rss)
    @rss_feed_html = "<link rel='alternate' title='Top Knows Feed' href='#{@rss_feed}' type='application/rss+xml'>"
    
    @right_ad_top = Ad.page(:home).zone(:right_top).get.code
    @right_ad_bottom = Ad.page(:home).zone(:right_bottom).get.code

    
    respond_to do |format|
      format.html # index.html.erb
      format.rss { render :layout => false }
    end

  end
  
  def login
    if logged_in?
      redirect_to home_url
    end
    @user = User.new(:referral_code => params[:referral_code])
  end
  
  def about
    @page_title = "About"
  end
  
  def privacy
    @page_title = "Privacy"
  end
  
  def intro_1
    @page_title = "Welcome"
  end
  
  def terms
    @page_title = "Terms and Conditions"
    if params[:no_layout]
      render :layout => false
    end
  end
  
  def upload
    redirect_to(new_video_path)
  end
  
  def help
    @page_title = "Help"
    if params[:no_layout]
      render :layout => false
    end
  end
  
  def contact
    @page_title = 'Contact'
  end
  
  def invite
    @page_title = "Invite your friends"
    @invite = Invite.new(params[:invite])
    if logged_in?
      @invite.first_name = self.current_user.name_first
      @invite.last_name = self.current_user.name_last
      @invite.email = self.current_user.email
    end unless params[:invite]
  end
  
  def invite_processor
    @invite = Invite.new(params[:invite])
    if @invite.save
      flash[:notice] = "Your invites have been sent."
      redirect_to home_url
    else
      @invite.friends = params[:invite][:friends]
      render :action => :invite
    end
  end
  
  def guidelines
  end
  
  def paginate_section
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
  
end
