class Admin::AdsController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required
  before_filter :set_ad_admin_active
  before_filter :get_adbackend
  
  
  def index
    @offer_list  = Ad.find(:all, :order => (params[:order] || 'offer_id'))
    @offers = @offer_list.paginate(:per_page => 20, :page => (params[:page] || 1))
    render :template => 'admin/ads/index'
  end
  
  def show
    @ad = @adbackend.ads.find(params[:id])
  end
  
  def new
    @ad  = @adbackend.ads.new
  end
  
  def create
    @ad  = @adbackend.ads.new(params[:ad])
    if @ad.save
      flash[:notice] = "Ad created"
      redirect_to admin_adbackend_path(@adbackend)
    else
      render :action => :new
    end
  end
  
  def edit
    @ad = @adbackend.ads.find(params[:id])
  end
  
  def update
    @ad = @adbackend.ads.find(params[:id])
    if @ad.update_attributes(params[:ad])
      flash[:notice] = "Ad updated"
      redirect_to admin_adbackend_ad_path(:adbackend_id => @adbackend.id, :id => @ad.id)
    else
      render :action => :edit
    end
  end
  
  def destroy
    @adbackend.ads.find(params[:id]).destroy
    redirect_to admin_adbackend_path(@adbackend)
  end
  
  private
  
  def get_adbackend
    @adbackend = Adbackend.find(params[:adbackend_id])
    redirect_to admin_adbackends_path unless @adbackend
    return true
  end
    
end
