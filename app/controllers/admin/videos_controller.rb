class Admin::VideosController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required

  def index
    SortHelper.columns = %w[
          name
          description
          user.login
          university
          class_number
          professor
          subject
          book_title
          book_author
        ]
        SortHelper.default_order = %w[login]
        @videos = Video.find(:all).sort do |a, b|
          SortHelper.sort(a, b, params)
        end
        
     @total = Video.count
                  @videos = Video.find(:all, :order => "created_at DESC").paginate(
                        :per_page => User.admin_per_page,
                        :page => params["page"] || 1)
        render :template => 'admin/videos/index'
  end
  
  def edit_video
    @video = Video.find(params[:id])
    if request.post?
      @video.update_attributes(params[:video])
      redirect_to admin_videos_path()
    end
        render :template => 'admin/videos/edit_video'
  end
  
  def delete_video
    
  end
  
end