class Admin::AdZonesController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required
  before_filter :get_adpage
  before_filter :set_ad_admin_active
  
  def index
    @ad_zones = @adpage.ad_zones
  end
  
  def new
    @ad_zone = @adpage.ad_zones.new
  end
  
  def create
    @ad_zone = @adpage.ad_zones.new(params[:ad_zone])
    if @ad_zone.save
      flash[:notice] = "Ad zone created"
      redirect_to admin_ad_page_ad_zone_path(:ad_page_id => @adpage.id, :id => @ad_zone.id)
    else
      render :action => :new
    end
  end
  
  def show
    @ad_zone = @adpage.ad_zones.find(params[:id])
  end
  
  def edit
    @ad_zone = @adpage.ad_zones.find(params[:id])
  end
  
  def update
    @ad_zone = @adpage.ad_zones.find(params[:id])
    if @ad_zone.update_attributes(params[:ad_zone])
      flash[:notice] = "Ad zone updated"
      redirect_to admin_ad_page_ad_zone_path(:ad_page_id => @adpage.id, :id => @ad_zone.id)
    else
      render :action => :edit
    end
  end  
  
  def destroy
    @adpage.ad_zones.destroy(params[:id])
    redirect_to admin_ad_zones_path
  end
    
 private
 
  def get_adpage
    @adpage = Adpage.find(params[:ad_page_id])
  end
  
end
