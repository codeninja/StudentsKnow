module Azoogle
  
  class Loader
    require 'yaml'
    attr_reader :azoogle_object
    def initialize(config_path)
      options = YAML.load_file(config_path)
      puts options.inspect
      @azoogle_object = Azoogle.new({ :publisher_id => options[:publisher_id],
                                      :login => options[:login],
                                      :password => options[:password]})                      
    end
  end

  class Azoogle
    require 'soap/rpc/driver'
    
    MAX_ATTEMPTS = 10
    SOAP_URL = 'https://login.azoogleads.com/soap/azads2_server.php'
    TRAFFIC_TYPE_IDS = {:email => 1, :display => 2, :search => 3, :popup => 4, :incentivized => 6}
    DEFAULT_TRAFFIC_TYPE = 2
    
    attr_reader :publisher_id, :login, :password, :login_hash, :last_update, :offer_categories, :offers
    
    def initialize(options={})
      @publisher_id = options[:publisher_id]
      @login = options[:login]
      @password = options[:password]
      
      raise "missing auth data" unless @publisher_id && @login && @password
      
      @driver = SOAP::RPC::Driver.new(SOAP_URL)
      @driver.wiredump_dev = STDOUT if options[:debug] == true
      add_soap_methods!
      
      raise "Authentication failure" unless authenticate
      
      @offer_ids = []
      @offers = []
      @offer_categories = []
    end
    
####### SOAP API METHODS
    def authenticate
      puts "soap calling authenticate"
      @login_hash = @driver.authenticate(@publisher_id,@login,@password)
      return (@login_hash.nil? ? false : true)
    end
    
    def logout
      puts "soap calling logout"
      msg = @driver.logout(@login_hash,@publisher_id)
      return (msg == 'Logged out successfully.' ? true : false)
    end
    
    def getList(offer_id,separator='~')
      puts "soap calling getList"
      emails = @driver.getList(@login_hash,@publisher_id,offer_id,separator)
      return nil unless emails.is_a?(String)
      return emails.split(separator)
    end
    
    def isSuppressed(email_address)
      puts "soap calling isSuppressed"
      result = @driver.isSuppressed(@login_hash,@publisher_id,offer_id,email_address)
      return (result == '1' ? true : false)
    end
    
    def getSubHits(offer_id,start_date=nil,end_date=nil,type_id=nil,sales_only=nil)
      puts "soap calling getSubHits"
      sd = (start_date.is_a?(Date) ? start_date.to_s : start_date)
      sd = nil unless sd.is_a?(String)
      ed = (end_date.is_a?(Date) ? end_date.to_s : end_date)
      ed = nil unless ed.is_a?(String)
      ti = (type_id.is_a?(Symbol) ? TRAFFIC_TYPE_IDS[type_id] : nil)
      sales_only ||= false
      result = @driver.getSubHits(@login_hash,@publisher_id,offer_id, sd,ed, ti, sales_only)
      # TODO: processing
      return result
    end
    
    def leadTotals(offer_id, start_date=nil, end_date=nil, type_id=nil, sales_only=nil)
      puts "soap calling leadTotals"
      sd = (start_date.is_a?(Date) ? start_date.to_s : start_date)
      sd = nil unless sd.is_a?(String)
      ed = (end_date.is_a?(Date) ? end_date.to_s : end_date)
      ed = nil unless ed.is_a?(String)
      ti = (type_id.is_a?(Symbol) ? TRAFFIC_TYPE_IDS[type_id] : nil)
      sales_only ||= false
      result = @driver.leadTotals(@login_hash, @publisher_id, offer_id, sd, ed, ti, sales_only)
      # TODO: processing
      
      return result
    end
    
    def offerDetails(offer_id, type_id=nil, sub_id=nil, keyword_delimeter='~')
      puts "soap calling offerDetails"
      type_id ||= 2
      results = @driver.offerDetails(@login_hash, @publisher_id, offer_id, type_id, sub_id, keyword_delimeter)
      return nil if results.nil?
      unless results.empty?
        return nil if results[0].is_a?(String)
        case type_id
          # TODO: implement other traffic types
          when 2
            the_offer = WebOffer.new
            the_offer.banner_creatives = results[0].banner_creatives if results[0].respond_to?("banner_creatives")
            the_offer.html_creatives = results[0].html_creatives if results[0].respond_to?("html_creatives")
            the_offer.flash_creatives = results[0].flash_creatives if results[0].respond_to?("flash_creatives")
            
        end
        the_offer.offer_id = offer_id
        the_offer.sub_id = sub_id
        the_offer.title = results[0].title
        the_offer.description = results[0].description
        the_offer.open_date = Date.parse(results[0].open_date)
        the_offer.expiry_date = Date.parse(results[0].expiry_date)
        the_offer.amount = results[0].amount        
        the_offer.categories = results[0].categories.collect{|c| c.downcase} if results[0].respond_to?("categories")
        the_offer.click_url = generateClickUrl(offer_id, type_id, sub_id)
        the_offer.last_update = Time.now
      else
        the_offer = nil
      end
      
      return the_offer
    rescue
      puts "Error parsing offer details for offer => #{offer_id}"
      puts results.inspect
      return nil
    end
    
    def listOffers
      puts "soap calling listOffers"
      result = @driver.listOffers(@login_hash, @publisher_id)
      return result
    end
    
    def generateClickUrl(offer_id, type_id=DEFAULT_TRAFFIC_TYPE, sub_id=nil)
      puts "soap calling generateClickUrl"
      result = @driver.generateClickUrl(@login_hash, @publisher_id, offer_id, type_id, sub_id)
      if result.match(/^http/i)
        return result
      else
        return nil
      end
    end
####### END SOAP API METHODS

    def offer_id_list
      init_offer_list!
      # TODO: Implement data expiration
      # return @offer_ids
      return @offer_ids[3..5]
    end
    
    def init_offer_list!
      if @offer_ids.empty?
        @offer_ids = listOffers
        @last_update = Time.now
      end
    end

    def offer(offer_id,sub_id,type_id=DEFAULT_TRAFFIC_TYPE)
      init_offer_list!
      the_sub_id = sub_id
      the_offer = @offers.select{ |o| ((o.offer_id.to_i == offer_id.to_i) and (o.sub_id == the_sub_id))}
      the_offer = the_offer.first
      if (the_offer.nil?)
        the_offer = create_offer!(offer_id,the_sub_id,type_id)
      end
      # TODO: Implement data expiration
      return the_offer
    end
    
    def random_offer(sub_id,type_id=DEFAULT_TRAFFIC_TYPE)
      the_offer = nil
      attempts = 1
      while (the_offer.nil? && attempts <= MAX_ATTEMPTS)
        the_offer = offer(offer_id_list[rand(offer_id_list.size - 1)], sub_id )
      end
      return the_offer
    end
    
    def random_creative(creative_type,sub_id,type_id=DEFAULT_TRAFFIC_TYPE)
      data = nil
      attempts = 1
      while(data.nil? && attempts <= MAX_ATTEMPTS)
        the_offer = random_offer(sub_id,type_id)
        ad = the_offer.send(creative_type.to_s + "_ad")
        unless ad.nil?
          data = ad.data
        end
        attempts += 1
      end
      return data
    end
    
    def random_banner(sub_id)
      return random_creative(:banner, sub_id)
    end
    
    def random_html(sub_id)
      return random_creative(:html, sub_id)
    end
    
    def random_flash(sub_id)
      return random_creative(:flash, sub_id)
    end

    def random_url(sub_id, type_id=DEFAULT_TRAFFIC_TYPE)
      the_url = nil
      attempts = 1
      while (the_url.nil? && attempts <= MAX_ATTEMPTS)
        the_offer = offer(offer_id_list[rand(offer_id_list.size - 1)], sub_id )
        the_url = the_offer.click_url unless the_offer.click_url.nil?
      end
      return {:title => the_offer.title, :url => the_offer.click_url}
    end
    
    def random_offer_by_category(category_name, sub_id=nil, type_id=DEFAULT_TRAFFIC_TYPE)
      the_offer = nil
      unless (possible_offers = offer_ids_by_category(category_name, sub_id, type_id)).empty?
        the_offer = possible_offers[rand(possible_offers.size - 1)]
      end
      return the_offer
    end
    
    def get_ads(in_options={},number=1)
      default_options = { :category => :all,
                          :sub_id => nil,
                          :dimensions => nil,
                          :ad_type => :url,
                          :type_id => DEFAULT_TRAFFIC_TYPE}
      options = default_options.merge(in_options)
      options[:ad_type] = :banner if options[:dimensions]
      the_ad = nil
      ad_list = []
      unless (possible_offer_ids = offer_ids_by_category(options[:category], options[:sub_id], options[:type_id])).empty?
        possible_ads = []
        possible_offer_ids.each do |po|
          offer_ads = offer(po, options[:sub_id], options[:type_id]).send(options[:ad_type].to_s + "_ad")
          offer_ads = [offer_ads] unless offer_ads.is_a?(Array)
          possible_ads += offer_ads
        end
        if options[:dimensions]
          (w,h) = options[:dimensions].split('x')
          possible_ads = possible_ads.select{|a| a.width == w.to_i && a.height == h.to_i}
        end
        number.times do
          the_ad = possible_ads[rand(possible_ads.size - 1)]
          ad_list << the_ad
          possible_ads.delete(the_ad)
        end
        the_ad = possible_ads[rand(possible_ads.size - 1)]
      end
      ad_list.compact!
      return ad_list
    end
    
    def offer_ids_by_category(category_name, sub_id=nil, type_id=DEFAULT_TRAFFIC_TYPE)
      all_offers = offer_id_list.collect{|oid| offer(oid,sub_id, type_id)}.compact
      if category_name == :all
        possible_offers = all_offers
      else
        possible_offers = all_offers.select{|o| o.categories.include?(category_name.to_s.downcase)}
      end
      possible_offer_ids = possible_offers.collect{|o| o.offer_id}
      return possible_offer_ids
    end

    private
    
    def add_soap_methods!
      @driver.add_method('authenticate','publisher_id','user_name','password')
      @driver.add_method('logout','login_hash','publisher_id')
      @driver.add_method('getList','login_hash','publisher_id','offer_id','separator')
      @driver.add_method('isSuppressed','login_hash','publisher_id','offer_id','email_address')
      @driver.add_method('getSubHits','login_hash','publisher_id','offer_id','start_date','end_date','type_id','sales_only')
      @driver.add_method('leadTotals','login_hash','publisher_id','offer_id','start_date','end_date','sub_id','type_id','sales_only')
      @driver.add_method('offerDetails', 'login_hash', 'publisher_id', 'offer_id', 'type_id', 'sub_id', 'keyword_delimeter')
      @driver.add_method('listOffers', 'login_hash', 'publisher_id')
      @driver.add_method('generateClickUrl', 'login_hash', 'publisher_id', 'offer_id', 'type_id','sub_id')
    end
    
    def update_offer!(the_offer,sub_id,type_id)
      new_offer = offerDetails(the_offer.offer_id,type_id)
      the_offer = new_offer
      return the_offer
    end

    def create_offer!(offer_id,sub_id,type_id)
      new_offer = offerDetails(offer_id,type_id,sub_id)
      unless new_offer.nil?
        @offers.reject!{|o| (o.offer_id.to_i == offer_id.to_i) && (o.sub_id == sub_id)}
        @offers << new_offer
      else
        @offer_ids.delete(offer_id)
      end
      return new_offer
    end
  
  end
                                
  class Offer
    attr_accessor :offer_id, 
                  :title, 
                  :description, 
                  :open_date, 
                  :expiry_date, 
                  :notices, 
                  :amount,
                  :last_update,
                  :categories,
                  :click_url,
                  :sub_id
    def initialize
      @last_update = Time.now
      init_offer_arrays!
    end
    
    def url_ad
      return {:title => title, :url => click_url}
    end
    
    private
    
    def init_offer_arrays!
      @categories = []
    end
  end
  
  class WebOffer < Offer
      attr_accessor :banner_creatives, :html_creatives, :flash_creatives
      
      def initialize
        super
      end
      
      def banner_creatives=(data)
        @banner_creatives = []
        populate_creatives!(@banner_creatives,data)
      end
      
      def html_creatives=(data)
        @html_creatives = []
        populate_creatives!(@html_creatives,data)
      end
      
      def flash_creatives=(data)
        @flash_creatives = []
        populate_creatives!(@flash_creatives,data)
      end
      
      def banner_ad
        return @banner_creatives[rand(@banner_creatives.size - 1)]
      end
      
      def html_ad
        return @html_creatives[rand(@html_creatives.size - 1)]
      end
      
      def flash_ad
        return @flash_creatives[rand(@flash_creatives.size - 1)]
      end
      
      private
      
      def init_offer_arrays!
        super
        @banner_creatives = []
        @html_creatives = []
        @flash_creatives = []
      end
      
      def populate_creatives!(creative_array,data_array)
        data_array.each do |ad_data|
          ad = Creative.new(ad_data.width, ad_data.height, ad_data.data)
          creative_array << ad unless ad.data.nil?
        end
      end
  end
  
  class Creative
    attr_accessor :width, :height, :data
    def initialize(ad_width, ad_height, ad_data)
      @width = ad_width.to_i
      @height = ad_height.to_i
      @data = ad_data
    end
  end
  
  class Array
    def uniq_by
      clean = []
      self.collect{|x| yield(x)}.uniq.each do |x|
        clean << self.select{|y| yield(y) == x}.last
      end
      clean
    end
  end
  
end