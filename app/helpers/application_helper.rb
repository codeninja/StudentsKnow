# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'bookrenter'
  
  def categories
    return Tag.find(:all, :conditions => 'is_category = 1')
  end 
  
  def nav_li(link_text,paths)
     #puts "request: " + request.env["REQUEST_PATH"].inspect + " path " + path.inspect
     highlight_paths = paths.to_a
     path = highlight_paths.first
     if (request.env["REQUEST_PATH"] == "") && (path == "/") 
       "<li class='sel_link' >#{link_to(link_text, path)}</li>"
     else
      "<li class='#{(highlight_paths.include?(request.env["REQUEST_PATH"]) || (not(highlight_paths.reject{|p| p == "/"}.select{|p| request.env["REQUEST_PATH"].match(p)}.empty?))) ? "sel_link" : "unsel_link"}'>#{link_to(link_text, path)}</li>"
    end
  end
  
  def nav_li_remote(link_text,path)
    "<li class='#{path == request.env["REQUEST_PATH"] ? "sel_link" : "unsel_link"}'>#{link_to_remote(link_text, :url => path)}</li>"
  end
  
  def admin_nav_li(link_text,path)
    "<li class='#{path == request.env["REQUEST_PATH"] ? "sel_link" : "unsel_link"}'>#{link_to(link_text, path)}</li>"
  end
  
  def nav_li2(path)
    "<li class='#{path == request.env["REQUEST_PATH"] ? "sel_link" : "unsel_link"}'>#{yield(path)}</li>"
  end
  
  def country_list
["United States", "Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos Islands", "Colombia", "Comoros", "Congo", "Congo", "Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and McDonald Islands", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norfolk Island", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territory", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Romania", "Russian Federation", "Rwanda", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia and Montenegro", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia", "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Virgin Islands", "British", "Virgin Islands", "U.S.", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]
  end
  
  def user_profile_pic_link(user)
    
    if user.is_a? User
      if user.profile_pic 
        link_to(image_tag(user.profile_pic.public_filename(:thumb),:size => "80x60"), user_path(user)) 
      else
        link_to(image_tag("default_avatar_80x60.png"), user_path(user)) 
      end
    end
  end
  
  def user_profile_pic_img(user)
    logger.info user.inspect
    image_tag(user.profile_pic.public_filename(:thumb), :size => "80x60") #if user.profile_pic if user.is_a? User
  end
  
  
  def show_time(time)
      if time > (Time.now - 1.day)
        #puts "greater than"
        return  time.to_s(:date_time12_only)
      else
       #puts "less than "
        return  time.to_s(:date_only)
      end
   end
  
  # def show_time(thetime)
  #  unless (thetime.to_f > Time.now - (Time.now - (60 * 60 * 24)))
  # puts thetime.to_s + " is older than a day"
  #  return  thetime.to_s(:date_only)
  #  else
  #  puts thetime.to_s + " is today"
  #  return  thetime.to_s(:date_time12_only)
  #  
  #  end
  #  end
  
    def bookmark_link(options,no_text=false)
      case options[:site]
        when :delicious
          href = "http://del.icio.us/post?url=#{options[:page_url]}&title=#{URI.encode(options[:page_title])}"
        when :google
          href = "http://www.google.com/bookmarks/mark?op=edit&output=popup&bkmk=#{options[:page_url]}&title=#{URI.encode(options[:page_title])}"
        when :reddit
          href = "http://reddit.com/submit?url=#{options[:page_url]}&title=#{URI.encode(options[:page_title])}"
        when :digg
          href = "http://digg.com/submit?phase=2&url=#{options[:page_url]}&title=#{URI.encode(options[:page_title])}"
        when :yahoo
          href = "http://myweb2.search.yahoo.com/myresults/bookmarklet?u=#{options[:page_url]}&t=#{URI.encode(options[:page_title])}"
        when :stumbleupon
          href= "http://www.stumbleupon.com/refer.php?url=#{options[:page_url]}&title=#{URI.encode(options[:page_title])}"
      end
      script = "window.open(this.href, '_blank', 'scrollbars=yes,menubar=no,height=600,width=750,resizable=yes,toolbar=no,location=no,status=no'); return false;"
  #    script = "link_open_window(this.href)"
      link_text = "<span class='bookmark_link_text'>#{image_tag((options[:site].to_s + ".png"), :alt => options[:link_title])}&nbsp;#{options[:site].to_s.capitalize unless no_text}</span>"
      link_to(link_text, href, {:onclick => script, :title => options[:link_title], :class => "site_bookmark_link"})
    end

    def expand_widget(id)
      link_to_function("expand", "expand_collapse('#{id}','#{id}_comment_expand_collapse_link')", :class => 'collapsed', :id => "#{id}_comment_expand_collapse_link")
    end


    def options_for_pagination(paginator_hash,section_id, other_opts={})
      if paginator_hash.is_a?(Hash)
        pagination_options = { :page => paginator_hash[:page_number], 
  						   :order => paginator_hash[:order], 
  						   :limit => paginator_hash[:limit],
  						   :tags => paginator_hash[:tags],
  						   :section_id => section_id,
  						   :user_id => paginator_hash[:user_id]}.merge(other_opts)
  			pagination_options.merge!({:search_string => paginator_hash[:search_string]}) if paginator_hash[:search_string]
			else
			  pagination_options =  {:section_id => section_id}.merge(other_opts)
		  end
		  return pagination_options
    end

    # Converts duration in the form "hh:mm:ss" to "mm:ss"
    def duration_as_minutes(length)
      t = length.match(/(\d\d):(\d\d):(\d\d)/)
      if t
        (hours,minutes,seconds) = [t[1].to_i, t[2].to_i, t[3].to_i]
        return sprintf("%d:%02d",(hours * 60 + minutes), seconds)
      else
        return 0
      end        
    end

    def know_categories
      Tag.find(:all, :conditions => "is_category = 1 AND name <> 'site-feedback'", :order => 'name asc')
    end
    
    def get_ads(options,number=1)
      # aaz = Azoogle::AzAdServer.new
      # aaz.get_ads(options,number)
      Ad.find_by_page(options,number)
    end

    def ad_link(code='sk')
      ad = get_ads({:ad_type => :url, :sub_id => code},5).first
      link_to(ad[:title], ad[:data])
    end
    
    def ad_banner(in_options,code='sk')
      default_options = {:ad_type => :banner, :sub_id => code}
      options = default_options.merge(in_options)
      ad = get_ads(options,1).first
      ad[:data] if ad
    end
    
    def strip_dashes(text)
      text.upcase.gsub(/-/,'&nbsp;')
    end

    def get_br_books(isbn)
      r = BookRenter::Search.instance.get(isbn,{},true)
      r = nil if r.error
      return r
    end
    


end