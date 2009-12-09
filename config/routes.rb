ActionController::Routing::Routes.draw do |map|
  map.resources :ad_zones

  map.resources :users
  
    map.home '/', :controller => 'home', :action => 'index'
    
    map.search '/search/:controller', :action => 'search'
    
    map.with_options :controller => 'home' do |h|
      h.about '/about', :action => 'about'
      h.privacy '/privacy', :action => 'privacy'
      h.terms '/terms', :action => 'terms'
      h.upload '/upload', :action => 'upload'
      h.signup '/signup', :action => 'login'
      h.login  '/login', :action => 'login'
      h.paginate_section '/paginate_list', :action => 'paginate_section'
      h.invite '/invite',  :action => 'invite'
      h.process_invite '/invite/send', :action => 'invite_processor'
      h.home_feed '/know.:format', :action => 'index'
      h.help '/help', :action => 'help'
      h.contact '/contact', :action => 'contact'
      h.guidelines '/guidelines', :action => 'guidelines'
      h.intro_1 '/intro_1', :action => 'intro_1'
    end
    
    
    map.activate '/activate/:activation_code',  :controller => 'account',  :action => 'activate' 
    map.forgot_password '/forgot_password',     :controller => 'account',  :action => 'forgot_password'
    map.reset_password '/reset_password/:id',   :controller => 'account',  :action => 'reset_password'
    map.change_password '/change_password',     :controller => 'account',  :action => 'change_password'
    
    map.ads '/ads.xml', :controller => 'ad_engine', :action => 'index'
  
    map.resource :session, :controller => 'sessions', :member => {:new => :get, :destroy => :post }
    
    map.resource :admin_session, :controller => 'admin/sessions', :member => {:new => :get, :destroy => :post }
    map.resources :users,  :has_many => [:videos], :has_one => :profile

    map.edit_password '/users/:id/edit_password', :controller => 'users', :action => 'edit_password'
    map.update_password '/users/:id/update_password', :controller => 'users', :action => 'update_password'

    map.resources :videos
    
    map.with_options :controller => 'videos' do |v|
      v.send_to_friend '/video/send_to_friend/:id', :action => 'send_to_friend'
      v.dirty_video '/dirty_video', :action => 'dirty'
      v.rate_video '/video/:id/rate/:rating', :controller => 'videos', :action => 'rate'
      v.swf_upload_video_asset '/video/upload_video/:upload_ticket', :controller => 'videos', :action => 'swf_create_asset'
      v.swf_upload_video_complete '/video/upload_complete/:upload_ticket', :controller => 'videos', :action => 'swf_upload_complete'
      v.edit_video_info '/video/:id/edit_info', :controller => 'videos', :action => 'update'
      v.videos_search '/videos/search', :action => 'search'
      v.videos_cat '/videos/category/:category', :action => 'index', :category => nil
      v.favorite_video '/video/:id/favorite', :action => 'favorite'
      v.remote_save_video_comment '/remote_save_video_comment/:id', :action => 'remote_save_video_comment'

      v.copy_embed_code '/video/copy_embed_code/:id', :action => 'copy_embed_code'
      v.send_email '/video/send_email/:id', :action => 'send_email'
      v.watch_video '/videos/:id', :action => 'videos'
      v.make_dirty '/video/make_dirty/:id/:user_id', :action => 'remote_make_dirty'
      v.confirm_video_delete '/videos/confirm_delete/:id', :action => 'confirm_delete'
      v.comment_comment '/videos/comments/reply/:id', :action => 'remote_comment_comment'
    end

    map.resources :account, 
      :controller => "account",
      :member=>{ :activate => 'get', :reset_password => 'get', :forgot_password => 'get' }
    
    map.resources :profiles
    
    map.admin '/admin', :controller => "admin/users", :action => "index"
    map.admin_login '/admin_login', :controller => "admin/sessions", :action => "login" 
    map.admin_logout '/admin_logout', :controller => "admin/sessions", :action => "destroy" 
    map.logout '/logout', :controller => 'sessions', :action => 'destroy'
    map.create '/create', :controller => 'account', :action => 'create'
    
    map.admin_new '/admin_new', :controller => 'admin/admins', :action => 'new'
    map.admin_create '/admin_create', :controller => 'admin/admins', :action => 'create'

    
    map.with_options :controller => 'profiles' do |p|
      p.create_profile '/profile/create', :action => 'create'
      p.save_profile '/profile/save_profile', :action => 'save'
      p.update_profile '/profile/update', :action => 'update'
      p.crop_image '/profile/image/crop', :action => 'crop_image'
      p.save_crop '/profile/image/save', :action => 'save_crop'
      p.replace_crop '/profile/image/replace', :action => 'replace_crop'
      p.image '/profile/image', :action => 'image' 
      p.dashboard '/profile/dashboard', :action => 'dashboard'
      p.profile_comments '/profile/comments/:id', :action => 'remote_profile_comments'
      p.save_comment '/profile/save_comment/:id', :action => 'remote_save_comment'
      p.delete_comment '/profile/delete_comment/:id', :action => 'remote_delete_comment'
    end

    map.resources :messages

    map.with_options :controller => 'messages' do |m|
      m.update_message '/messages/:id/edit', :action => 'update'
      m.messages '/message_board', :action => 'index'
      m.message_category '/message_board/:id', :action => 'category'
      m.message_category_messages '/message_board/:category/messages/:id', :action => 'message'
      m.create_message '/create_message/:id', :action => "create"
      m.messages_search '/message_board/search', :action => "search"
      m.create_message_comment '/message_board/messages/:message_id/comments/new', :action => 'create_comment'
      m.edit_message_comment '/messages/:message_id/comments/edit/:id', :action => 'edit_comment'
      m.update_message_comment '/messages/:message_id/comments/update/:id', :action => 'update_comment'
      m.destroy_message_comment '/messages/:message_id/comments/destroy/:id', :action => 'destroy_comment'
    end
    

    
   map.with_options :controller => 'admin/users' do |au|
     au.admin_users '/admin_users', :action => 'index'
     au.admin_edit_user '/admin_edit_user/:id', :action => 'edit'
     au.admin_delete_user '/admin_delete_user/:id', :action => 'delete_user' ,:confirm => "Deleting a user cannot be undone, are you sure?"
     au.admin_users_search '/admin_users_search', :action => "search"
     au.admin_user_videos '/admin_user_videos/:id', :action => "videos"
     au.admin_user_list_export '/admin_users/export', :action => "export_list"
  end
   
   map.with_options :controller => 'admin/videos' do |av|
     av.admin_videos '/admin_videos', :action => 'index'
     av.admin_edit_video '/admin_edit_video/:id', :action => 'edit_video'
     av.admin_delete_video '/admin_delete_video/:id', :action => 'delete_video', :confirm => "Deleting a video cannot be undone, are you sure?"
   end
   
  map.with_options :controller => 'admin/messages' do |am|
     am.admin_messages '/admin_messages/:id', :action => 'index', :id => nil
     am.admin_edit_message '/admin_edit_message/:id', :action => 'edit_message'
     am.admin_delete_message '/admin_delete_message/:id', :action => 'delete_message'
     am.admin_search '/admin/search', :action => 'messages_search'
     am.show_cat_messages '/admin/show_cat_messages/:id', :action => "show_cat_messages"
     am.admin_replies_list '/admin/admin_replies_list/:id' , :action => "show_replies_list"
     am.admin_edit_reply '/admin_edit_reply/:id', :action => 'edit_reply'
     am.admin_delete_reply '/admin_delete_reply/:id', :action => 'delete_reply'
  end
   
   map.with_options :controller => 'admin/system' do |as|
     as.admin_system '/admin_system', :action => 'index'
     as.edit_rate '/edit_rate/:id', :action => 'edit_rate'
     as.update '/update', :action => 'update'
   end
  
  
  map.with_options :controller => 'admin/revenues' do |ar|
     ar.admin_revenues '/admin_revenues', :action => 'index'
   end
  
  
   map.with_options :controller => 'admin/dirties' do |ar|
      ar.admin_dirties '/admin_dirties', :action => 'index'
      ar.admin_edit_dirty '/admin_edit_dirty/:id', :action => 'edit'
      ar.admin_approve_dirty '/approve/:id', :action => 'approve'
    end
    
    map.with_options :controller => 'admin/ads' do |ad|
      ad.admin_ads '/admin/ads/', :action => 'index'
    end
    
    map.namespace(:admin) do |admin|
      admin.resources :ad_zones
      admin.resources :adbackends, :has_many => :ads
      admin.resources :ad_pages, :has_many => [:ads, :ad_zones]
      
      admin.resources :ads
    end
  


  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
