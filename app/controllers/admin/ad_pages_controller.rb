class Admin::AdPagesController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required
  before_filter :set_ad_admin_active
  
  def index
    @adpages = Adpage.find(:all)
  end
  
  def show
    @adpage = Adpage.find(params[:id])
  end
  
  def new
    @adpage = Adpage.new
  end
  
  def update
    @adpage = Adpage.find(params[:id])
    if @adpage.update_attributes(params[:adpage])
      flash[:notice] = "Ad page updated"
      redirect_to admin_ad_page_path(@adpage)
    else
      
    end
  end
  
  def edit
    @adpage = Adpage.find(params[:id])
  end
  
  def create
    @adpage = Adpage.new(params[:adpage])
    if @adpage.save
      flash[:notice] = "Ad Page Created"
      redirect_to admin_ad_page_path(@adpage)
    else
      render :action => :new
    end
    
  end
  
  def destroy
    Adpage.destroy(params[:id])
    redirect_to admin_ad_pages_path
  end
  
end
