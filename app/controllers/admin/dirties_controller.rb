class Admin::DirtiesController < ApplicationController
  layout "admin/admin"

   before_filter :admin_login_required

  def index
    @total = Video.count
    dirty_votes = Rating.find(:all, :conditions => "rateable_type='Video' AND value=-1")
    
    @videos = []
    for dv in dirty_votes
      vid = Video.find(dv.rateable_id)
      @videos << vid
    end
    
    
    @dirties = @videos.paginate(
          :per_page => User.admin_per_page,
          :page => params["page"] || 1)
    render :template => 'admin/dirties/index'
  end
  
  def approve
     respond_to do |format|      
        format.html do
            @video = Video.find(params[:id])
            @video.update_attributes(:approved => true)
            redirect_to admin_dirties_path
        end
    end
    
    render :template => 'admin/dirties/approve'
  end
  
  def edit
    @video =Video.find(params[:id])
      @user = self.current_user
      @video = Video.find(params[:id])
      @video.referral_hit(params[:rc])

      @my_referral_code = @video.referral_code((logged_in? ? self.current_user : nil))
      @share_url = video_path(:id => @video.id, :rc => @my_referral_code)
    
     @advert_loc = "http://#{request.env["HTTP_HOST"]}/ads.xml?rc=#{@my_referral_code}"
      @swf_loc = "http://#{request.env["HTTP_HOST"]}/flash/FLVPlayer.swf"
      @flashvars = "videoURL=http://#{request.env["HTTP_HOST"]}#{@video.videoasset.public_filename()}&advertURL=#{@advert_loc}"
      
       respond_to do |format|      
          format.html do
            @related_videos = Video.find_with_tags(@video.tag_list, :limit => 5)
            @users = User.find(:all, :order => "created_at DESC").paginate(
                  :per_page => User.admin_per_page,
                  :page => params["page"] || 1)
            @comments = @video.comments.reverse.paginate(
                  :per_page => 5,
                  :page => params["page"] || 1)
            @rss_feed_html = "<link rel='alternate' title='Top Videos Feed' href='http://#{request.env["HTTP_HOST"]}#{formatted_video_path(@video, :rss)}' type='application/rss+xml'>"
            @page_title = 'Video: ' + @video.name
          end

          format.js do
            render :partial => "videos/embed_video", :layout => false
          end

          format.xml  { render :xml => @video }
          format.rss { render :layout => false }
      end
  
    render :template => 'admin/dirties/edit'
  end
end
