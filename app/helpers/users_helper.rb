module UsersHelper
  
  def asset_menus_json(is_my_profile,assets,asset_menu_var="asset_menus")
    out = []
    assets.each do |asset|
      links = []
      links << link_to('WATCH', video_path(asset))
      if is_my_profile
        links << link_to('DELETE', confirm_video_delete_path(asset))
        links << link_to('EDIT', edit_video_path(asset))
      end
      # links << link_to('SEND TO FRIEND', send_to_friend_path(asset))
      links << link_to('COPY EMBED CODE', copy_embed_code_path(asset))
      out_entry = ["asset_#{asset.id}", links.join(" ")]
      out << out_entry
    end
    json = out.collect{|a| "#{asset_menu_var}['#{a[0]}'] = '#{a[1]}'"}.join(",\n")
    return json
  end
  
  
  def favorite_menus_json(is_my_profile,assets,asset_menu_var="asset_menus")
    out = []
    assets.each do |asset|
      links = []
      links << link_to('WATCH', video_path(asset))
      if is_my_profile
        links << link_to('DELETE FROM FAVORITES', favorite_video_path(:id => asset.id) + "?favorite=false&redirect=true")
      end
      # links << link_to('SEND TO FRIEND', send_to_friend_path(asset))
      links << link_to('COPY EMBED CODE', copy_embed_code_path(asset))
      out_entry = ["favorite_#{asset.id}", links.join(" ")]
      out << out_entry
    end
    json = out.collect{|a| "#{asset_menu_var}['#{a[0]}'] = '#{a[1]}'"}.join(",\n")
    return json
  end
  
  def viewed_videos_menus_json(is_my_profile,assets,asset_menu_var="asset_menus")
    out = []
    assets.each do |asset|
      links = []
      links << link_to('WATCH', video_path(asset))
      links << link_to('COPY EMBED CODE', copy_embed_code_path(asset))
      out_entry = ["viewed_#{asset.id}", links.join(" ")]
      out << out_entry
    end
    json = out.collect{|a| "#{asset_menu_var}['#{a[0]}'] = '#{a[1]}'"}.join(",\n")
    return json
  end
  
  def rated_videos_menus_json(is_my_profile,assets,asset_menu_var="asset_menus")
    out = []
    assets.each do |asset|
      links = []
      links << link_to('WATCH', video_path(asset))
      links << link_to('COPY EMBED CODE', copy_embed_code_path(asset))
      out_entry = ["rated_#{asset.id}", links.join(" ")]
      out << out_entry
    end
    json = out.collect{|a| "#{asset_menu_var}['#{a[0]}'] = '#{a[1]}'"}.join(",\n")
    return json
  end
  
  def menued_asset(abject, asset_class)
    link_to(image_tag(object.asset.public_filename(:thumb), 
						:onmouseover => "#{"showmenu(event,asset_menus['#{asset_class}_#{object.id}'], #{object.id}, asset_class, 200)" }", 
						:onmouseout=>"delayhidemenu()"), eval("#{object.class.to_s.downcase}_path(object)"))
  end
  
end