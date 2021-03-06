# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.login + "'s " if @user }Videos"
    xml.description @page_title
    xml.link("http://" + request.env["HTTP_HOST"] + formatted_videos_path(:rss))
    xml.category(@category)
    for video in @videos[:page]
      xml.item do
        xml.title video.name
        xml.description video.description
        xml.author video.user.login
        xml.pubDate video.created_at.to_s(:rfc822)
        xml.link("http://" + request.env["HTTP_HOST"] + formatted_video_path(video, :rss))
        xml.guid("http://" + request.env["HTTP_HOST"] + formatted_video_path(video, :rss))
      end
    end
  end
end

