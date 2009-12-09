class Admin::AdbackendsController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required
  before_filter :set_ad_admin_active
  
  def index
    @adbackends = Adbackend.find(:all)
  end
  
  def show
    @adbackend = Adbackend.find(params[:id])
  end
  
  def new
    @adbackend = Adbackend.new
  end
  
  def create
    @adbackend = Adbackend.new(params[:adbackend])
    if @adbackend.save
      redirect_to admin_adbackend_path(@adbackend)
    else
      flash[:notice] = "Error Saving Ad backend"
      render :action => :new
    end
  end
  
  def update
    @adbackend = Adbackend.find(params[:id])
    if @adbackend.update_attributes(params[:adbackend])
      flash[:notice] = "Adbackend saved"
    else
      render :action => :edit
    end
  end
  
  def destroy
    Adbackend.destroy(params[:id])
    redirect_to admin_adbackends_path
  end
end
