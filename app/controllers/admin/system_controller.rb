class Admin::SystemController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required

  def index
    @rates = Rate.find(:all)
    if request.post?
          @rate = Rate.new(params[:rate])
          if @rate.save
            redirect_to admin_system_path
          end
    end
    render :template => 'admin/system/index'
  end
  
  
  def edit_rate
      @rate = Rate.find(params[:id])
      if request.post?
        @rate = Rate.find(params[:id])
        if @rate.update_attributes(params[:rate])
            redirect_to admin_system_path
        end
      end
          render :template => 'admin/system/edit_rate'
  end
  
  def update
      @rate = Rate.find(params[:id])
      if @rate.update_attributes(params[:rate])
          redirect_to admin_system_path
      end
  end

end
