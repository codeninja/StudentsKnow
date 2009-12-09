# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Knows"
    xml.description @page_title
    xml.link(home_feed_url)
    xml.category(@category)
    for know in @knows[:page]
      xml.item do
        xml.title know.name
        xml.description know.description
        xml.author know.user.login
        xml.media know.class.to_s
        xml.pubDate know.created_at.to_s(:rfc822)
        xml.link("http://" + request.env["HTTP_HOST"] + eval("formatted_#{know.class.to_s.downcase}_path(know, :rss)"))
        xml.guid("http://" + request.env["HTTP_HOST"] + eval("formatted_#{know.class.to_s.downcase}_path(know, :rss)"))
      end
    end
  end
end

