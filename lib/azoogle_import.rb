class AzoogleImport
  require 'csv'
  require 'yaml'
  
  def initialize
    @backend = Adbackend.find_by_name("azoogle")
    raise "Ad backend not found! => #{name}" unless @backend
    @page_names = Adpage.find(:all).collect{|ap| [ap.name, ap]}
  end
  
  def import!(in_csv_filename=nil,in_mapping_filename=nil)
    raise "Ad backend not found! => #{name}" unless @backend
    (@csv_file, @mapping) = open_files(in_csv_filename, in_mapping_filename)
    
    row_index = 0
    CSV::Reader.parse(@csv_file) do |row|
      unless row_index == 0
        ad = map_and_make_ad(row)
      end
      row_index += 1
    end
    
  end
  
  private 
  
  def open_files(csv_filename,mapping_filename)
    if csv_filename.nil?
      csv_filename = "#{RAILS_ROOT}/config/#{backend.name}_ads.csv"
    end
    csv_file = File.open(csv_filename)
    raise "Ad CSV not found => #{mapping_filename}" unless csv_file

    if mapping_filename.nil?
      mapping_filename = "#{RAILS_ROOT}/config/#{backend.name}_csv_mapping.yml"
    end
    mapping_file = File.open(mapping_filename)
    raise "CSV Mapping description not found => #{mapping_filename}" unless mapping_file
    mapping = YAML.load(mapping_file.read)

    return [csv_file,mapping]
  end
  
  def map_and_make_ad(row)
    attrs = {}
    attrs[:adbackend_id] = @backend.id
    # puts "Creating Ad..."
    Ad.column_names.collect{|n| n.to_sym}.each do |field|
      unless @mapping[field].nil?
        # puts "  - Setting #{field} with column #{@mapping[field]} => "
        attrs[field] = row[@mapping[field]] 
      end
    end
    
    ad = Ad.new(attrs)
    
#    pages_for(row).each do |page|
#        ad.adpages << page
#    end
    
    if ad.save
      # puts " * Created ad => #{ad.inspect}"
      if (ad.width.nil? && ad.height.nil?)
        ad.text_only = true
        ad.size = "text"
        ad.save
      end
    end
  end
  
#  def pages_for(row)
#    pages = []
#    home_state = (row[@mapping[:homepage]] || '').downcase
#    video_state = (row[@mapping[:videopage]] || '').downcase
#    other_pages = (row[@mapping[:otherpage]] || '').downcase
#    
#    if home_state == 'yes'
#      page = Adpage.find_by_name('home')
#      pages << page
#    end
#    
#    if video_state == 'yes'
#      page = Adpage.find_by_name('video')
#      pages << page
#    end
#    
#    unless other_pages.empty?
#      page = Adpage.find_by_name(other_pages)
#      if page
#        pages << page
#      else
#        puts "adpage wasnt found with name #{other_pages}"
#      end
#    end
#    
#    return pages.compact
#  end
  
end