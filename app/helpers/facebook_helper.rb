module FacebookHelper
    
  def profile_feeds
    %w{my_videos my_favorites new_knows top_knows most_discussed most_viewed}
  end
  
  def profile_feed_knows(user,option, limit=5)
    case option
      when "my_videos"
        knows = user.public_videos[0..(limit-1)]
      when "my_favorites"
        knows = user.favorite_knows[0..(limit-1)]
      when "new_knows"
        knows = Video.find_with_tags([], {:order => 'date', :limit => 5})
      when "top_knows"
        knows = Video.find_with_tags([], {:order => 'rating', :limit => 5})
      when "most_discussed"
        knows = Video.find_with_tags([], {:order => 'comments', :limit => 5})
      when "most_viewed"
        knows = Video.find_with_tags([], {:order => 'views', :limit => 5})
    else
      if (id = (option || "").split('_').last.to_i) > 0
        feed = KnowFeed.find(id)
        knows = feed.knows
      else
        logger.info "Defaulting to default know list for Facebook profile feed."
        knows = profile_feed_knows(user, "my_favorites", limit)
      end
    end
    return knows
  end
  
  def feed_description(option)
  	case option
      when "my_videos"
        desc = "My Videos"
      when "my_favorites"
  		desc = "My Favorites"
      when "new_knows"
  		desc = "New Knows on StudentsKnow.com"
      when "top_knows"
        desc = "Top Knows on StudentsKnow.com"
      when "most_discussed"
  		desc = "Most Discussed Knows on StudentsKnow.com"
      when "most_viewed"
  		desc = "Most Viewed on StudentsKnow.com"
    else
      if (id = (option || "").split('_').last.to_i) > 0
        feed = KnowFeed.find(id)
        desc = "My Feed: " + h(feed.name)
      else
        logger.info "Defaulting to default know list for Facebook profile feed."
  		desc = "My Favorites"
      end
    end
    return desc
  end
  
end
