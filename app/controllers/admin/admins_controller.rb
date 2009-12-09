class Admin::AdminsController < ApplicationController
    layout "admin/admin"
    before_filter :admin_login_required
    
  def create 
    @admin = Admin.new(params[:admin])
    respond_to do |format|
      if @admin.save
        format.xml  { render :xml => @admin.to_xml }#FLEX
        format.html do
          flash[:notice] = 'Your account was created.'
          redirect_to admin_users_path
        end
      else
        
      # puts @admin.inspect
        format.xml { render :xml => @admin.errors.to_xml_full }#FLEX
        format.html { render :action => 'new' }
      end
    end    
    render :template => 'admin/admins/create'
    
  end
  
  
  def new
    @admin = Admin.new
    params[:admin].delete('form') if params[:admin]
    render :template => 'admin/admins/new'
  end
  
  
end
