class Admin::UsersController < ApplicationController
  require 'csv'
   layout "admin/admin"
   before_filter :admin_login_required

   
   def index
        @total = User.count
        @users = User.find(:all, :order => "created_at DESC").paginate(
              :per_page => User.admin_per_page,
              :page => params["page"] || 1)
        render :template => 'admin/users/index'
   end
   
   def search
     @item = params[:admin_user_search][:item]
      @users = User.find(:all, :conditions => ["login like ?  OR email like ? ", "%#{params[:admin_user_search][:item]}%", "%#{params[:admin_user_search][:item]}%"])
      render :template => 'admin/users/search'
   end
   
   def edit
     @user = User.find(params[:id])
     if request.post?
           respond_to do |format|
              if @user.update_attributes(params[:user])
                format.xml  { render :xml => @user.to_xml }#FLEX
                format.html do
                  flash[:notice] = 'The user account was updated'
                  redirect_to admin_users_path()
                end
              else
                format.xml { render :xml => @user.errors.to_xml_full }#FLEX
                format.html { render :action => 'edit' }
              end
            end
          end
          render :template => 'admin/users/edit'
   end
   
   def videos
     @videos = Video.find :all, :conditions => ["user_id = ?", params[:id].to_i]
     render :template => 'admin/users/videos'
   end
   
   def export_list
     arr = User.find(:all, :include => :videos).collect{ |user|
         [ user.login, 
                user.email, 
                "#{user.name_first} #{user.name_last}",
                user.referral_code,
                user.created_at.to_s(:long),
                user.videos.compact.select{|v| v.status == 2 if v.videoasset}.size]}
    csv_data = arr.collect{|r| r.join(', ')}.join("\r\n")        
    send_data csv_data, :type => "application/vnd.ms-excel", :filename => "user_list-#{Date.today.to_s}.csv"
   end
  
end
