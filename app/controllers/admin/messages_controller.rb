class Admin::MessagesController < ApplicationController
  layout "admin/admin"

   before_filter :admin_login_required
   
  
  def index
    if params[:id] && (params[:id] != "0")
      #show the specified category messages
    
          @cat = Tag.find(params[:id])
          @messages = Message.find_tagged_with(@cat, :order => "created_at DESC").paginate(
            :per_page => Message.admin_per_page,
            :page => params["page"] || 1)
          @search_all = 0
    end
     @categories = Tag.find(:all, :conditions => 'is_category = 1')
     if request.post?
       puts "answering a post request...."
       if params[:id]
         puts "I have params id and is " + params[:id]
          if params[:id] == "0" || params[:admin_message_search][:clear_filter] == "1"
            puts "i'm doing the main search here..."
             @search_messages = Message.find(:all, :conditions => ["topic like ?  OR data like ? ", "%#{params[:admin_message_search][:item]}%", "%#{params[:admin_message_search][:item]}%"]).paginate(
            :per_page => Message.admin_per_page,
            :page => params["page"] || 1)
            @search_all = 1
        
          else
               @search_all = 0
               puts "I think I have a cat id"
               @cat = Tag.find(params[:id])
                #@search_messages = Message.find_tagged_with(@cat, :conditions => ["topic like ? OR data like ?","%#{params[:admin_message_search][:item]}%", "%#{params[:admin_message_search][:item]}%" ]).paginate(
                @search_messages = Message.find_tagged_with(@cat, :conditions => ["topic like ?","%#{params[:admin_message_search][:item]}%" ]).paginate(

                  :per_page => Message.admin_per_page,
                  :page => params["page"] || 1)
          end
       else
          @search_all = 0
          @search_messages = Message.find(:all, :conditions => ["topic like ?  OR data like ? ", "%#{params[:admin_message_search][:item]}%", "%#{params[:admin_message_search][:item]}%"]).paginate(
            :per_page => Message.admin_per_page,
            :page => params["page"] || 1)
       end
     end
     render :template => 'admin/messages/index'
  end
  
  #def messages_search
  #      @messages = Message.find(:all, :conditions => ["topic like ?  OR data like ? ", "%#{params[:admin_message_search][:item]}%", "%#{params[:admin_message_search][:item]}%"])
  #end
  
  
  def show_cat_messages
    @cat = Tag.find(params[:id])
    @messages = Message.find_tagged_with(@cat, :order => "created_at DESC").paginate(
        :per_page => Message.admin_per_page,
 	:page => params["page"] || 1)
  end
  
  def show_replies_list
    @message = Message.find(params[:id])
    @replies = @message.comments
  end
  
  def edit_message
    @message = Message.find(params[:id])
    @cat_id = Tag.find(:first, :conditions => "name = '#{@message.category}'").id
    if request.post?
      @message.update_attributes(params[:message])
      redirect_to admin_messages_path(:id => @cat_id)
    end
    render :template => 'admin/messages/edit_message'
  end
  
  def delete_message
    message = Message.find(params[:id])
    cat = Tag.find(:first, :conditions => "name = '#{message.category}'")
    message.destroy
    redirect_to admin_messages_path(:id => cat.id)
  end
  
  def edit_reply
    @comment = Comment.find(params[:id])
    @message = Message.get_parent(@comment)
    if request.post?
      @comment.update_attributes(params[:comment])
      redirect_to admin_replies_list_path(:id => @message.id)
    end
    render :template => 'admin/messages/edit_reply'
  end
  
  def delete_reply
    reply = Comment.find(params[:id])
    message = Message.get_parent(reply)
    reply.destroy
    flash[:notice] = "Reply deleted!"
    redirect_to admin_replies_list_path(:id => message.id)
    
  end
end
