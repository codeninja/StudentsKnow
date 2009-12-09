namespace :ads do 
  namespace :azoogle do
    
    desc "Import Ad Data from CSV"
    task :import_banners => :environment do
      require 'azoogle_import'
      
      csv_file = (ENV["csv"] || "#{RAILS_ROOT}/config/azoogle_ads.csv")
      mapping_file = (ENV["mapping"] || "#{RAILS_ROOT}/config/azoogle_csv_mapping.yml")
      
      adbackend = Adbackend.find_by_name("azoogle")
      
      puts "Destroying all Azoogle Banner Ads..."
      adbackend.ads.find(:all, :conditions => "size <> 'text'").each{|a| a.destroy}
      
      az = AzoogleImport.new
      
      puts "Importing Banner Ads..."
      az.import!(csv_file, mapping_file)      
    end
  
    desc "Import Text Ad Data from CSV"
    task :import_text_ads => :environment do
      require 'azoogle_import'
      
      csv_file = (ENV["csv"] || "#{RAILS_ROOT}/config/azoogle_text_ads.csv")
      mapping_file = (ENV["mapping"] || "#{RAILS_ROOT}/config/azoogle_text_ads_csv_mapping.yml")
      
      adbackend = Adbackend.find_by_name("azoogle")
      
      puts "Destroying all Azoogle Text Ads..."
      adbackend.ads.find(:all, :conditions => "size = 'text'").each{|a| a.destroy}
      
      az = AzoogleImport.new
      
      puts "Importing Text Ads..."
      az.import!(csv_file, mapping_file)
    end
    
    desc "Import All Azoogle Ads"
    task :import_all => [:import_banners, :import_text_ads] do
    end
  
  end
end