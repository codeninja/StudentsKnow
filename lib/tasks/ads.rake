namespace :ads do
  desc "Bootstrap the Ad system"
  task :bootstrap => :environment do
    require 'yaml'
    
    ad_data = <<EOF
--- 
- :name: home
  :zones: 
  - - right_top
    - block
  - - right_bottom
    - block
  - - left_1
    - block
  - - left_2
    - block
- :name: message_board
  :zones: 
  - - right_top
    - tall
  - - right_bottom
    - tiny
  - - left_1
    - block
  - - left_2
    - block
- :name: video
  :zones: 
  - - right_top
    - block
  - - right_bottom
    - block
  - - left_1
    - block
  - - left_2
    - block
- :name: text_ads
  :zones: 
  - - default
    - text
EOF
    
    Adbackend.destroy_all
    Adpage.destroy_all
    
    Adbackend.create(:name => "azoogle")
    
    pages = YAML.load(ad_data)
    pages.each do |page|
      puts " * Creating AdPage => %s" % page[:name]
      new_page = Adpage.create(:name => page[:name])
      page[:zones].each do |zone|
        puts "  - Creating AdZone => %s (%s)" % zone
        new_zone = AdZone.new(:name => zone[0], :size => zone[1])
        new_page.ad_zones << new_zone
      end
    end
  end
  
end