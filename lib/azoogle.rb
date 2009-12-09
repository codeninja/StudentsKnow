module Azoogle
  require 'yaml'
  require 'soap/rpc/driver'
  require 'date'
  
  DEFAULT_REFCODE = '~RefCodeHere~'
  
  class AzAdServer
    
    def initialize(az_account=nil,referrer_code=nil)
      
      if az_account.nil?
        @az_account = (AzoogleAccount.find(:first) || AzoogleAccount.create)
      else
        @az_account = az_account
      end
      
      @driver = AzApiDriver.new(false)
      
      if @az_account.offers.empty?
        init_offer_list!(referrer_code)
      end
    end
    
    def get_ads(in_options,number=1)
      default_options = { :category => :all,
                          :sub_id => nil,
                          :dimensions => nil,
                          :ad_type => :url }
      options = default_options.merge(in_options)
      

      refcode = options[:sub_id]

      if options[:dimensions]
        options[:ad_type] = :banner 
        dimension_fuzzyness = 50
        (width, height) = options[:dimensions].to_s.split('x').collect{|x| x.to_i}
        if ((width > 1) and (height > 1))
          min_width = (width - dimension_fuzzyness).to_s
          min_height = (height - dimension_fuzzyness).to_s
        else
          width = height = nil
        end
      else
        width = height = nil
      end

      condition_hash = {  :sub_id => DEFAULT_REFCODE,
                          :creative_type => options[:ad_type].to_s,
                          :width => width,
                          :height => height
                       }
                       
      build_condition_array = []
      build_condition_array << (DEFAULT_REFCODE ? '(azoogle_creatives.sub_id = :sub_id)' : nil)
      build_condition_array << "(((azoogle_creatives.width = #{width}) AND (azoogle_creatives.height = #{height})) OR (((azoogle_creatives.width > #{min_width}) AND (azoogle_creatives.width < #{width}) ) AND ((azoogle_creatives.height > #{min_height}) AND (azoogle_creatives.height < #{height})  )))" if width
      build_condition_array << "(creative_type = :creative_type)"
      
  
      # number += 3
      ads = []
      attempts = 0
      while ((ads.size < number) and (attempts < 10))
        if ((options[:category] != :all) or (options[:ad_type].to_s == 'url'))
          # added a limit to query to limit the time required to generate creatives for the given sub_id
          offers = AzoogleOffer.find(:all, :include => :categories, :conditions => "azoogle_offer_categories.name IN (#{options[:category].to_a.collect{|c| "'#{c}'"}.join(',')})", :order => "RAND()", :limit => 2)
          offers.each do |theoffer|
            refresh_offer!(theoffer, DEFAULT_REFCODE) if theoffer.creatives.count < 1
          end
          condition_string = build_condition_array.compact.join(' AND ')
          ads += AzoogleCreative.find( :all, 
                                       :conditions => [condition_string, condition_hash], 
                                       :limit => number, 
                                       :select => "DISTINCT azoogle_creatives.data, azoogle_creatives.*", 
                                       :order => "RAND()")
        else
          # offers = AzoogleOffer.find(:all, :order => 'RAND()', :limit => number)
          # offers.each do |theoffer|
          #   refresh_offer!(theoffer, DEFAULT_REFCODE) if theoffer.creatives.count < 1
          # end
          # build_condition_array << "(azoogle_creatives.azoogle_offer_id IN (#{offers.collect{|o| "'#{o.id}'"}.join(',')}))"
          condition_string = build_condition_array.compact.join(' AND ')
          ads += AzoogleCreative.find( :all, 
                                       :conditions => [condition_string, condition_hash], 
                                       :limit => number, 
                                       :select => "DISTINCT azoogle_creatives.data, azoogle_creatives.*", 
                                       :order => "RAND()")
        end
        # ads = ads.uniq_by{|ad| ad.offer.offer_id}
        attempts += 1
      end

      ad_hash_array = ads.collect{|a| {:title => a.offer.title, :data => a.data.gsub(/#{DEFAULT_REFCODE}/,refcode), :dimensions => "#{a.width}x#{a.height}"}}
      # ad_hash_array = ad_hash_array[0..(number - 4)]
      return ad_hash_array
    end
    
   # private
    
    def init_offer_list!(referrer_code=nil)
      offer_list = @driver.listOffers
      existing_offer_ids = @az_account.offers.collect{|o| [o.offer_id, referrer_code]}
      
      offer_list.each do |offer|
        unless existing_offer_ids.include?([offer, referrer_code])
          new_offer = AzoogleOffer.new(:azoogle_account_id => @az_account.id, :offer_id => offer)
          # refresh_offer!(new_offer, referrer_code, true)
          refresh_offer!(new_offer, DEFAULT_REFCODE, true)
        end
      end
      @az_account.reload
    end

    def refresh_offer!(offer, referrer_code, get_creatives=true)
      stale_data = (offer.updated_at.nil? ? 24.hours.ago : offer.updated_at) < (12.hours.ago - rand(10).minutes)
      
      if stale_data or get_creatives
        new_offer = @driver.offerDetails(offer.offer_id, nil, referrer_code)
        unless new_offer.nil?
          # Map data to AR model instance if updated before around 12 hours ago
          if stale_data
            offer.title = new_offer.title
            offer.description = new_offer.description
            offer.open_date = new_offer.open_date
            offer.expiry_date = new_offer.expiry_date
            offer.amount = new_offer.amount
            
            offer.categories = []
            new_offer.categories.each do |category_name|
              cat = AzoogleOfferCategory.find_or_create_by_name(category_name.downcase)
              offer.categories << cat
            end
            
            offer.save
          end
        
          if get_creatives
            new_offer.click_url = @driver.generateClickUrl(offer.offer_id,2,referrer_code)
            
            # offer.creatives.find(:all, :conditions => ["sub_id = ?", referrer_code]).each{|c| c.destroy}
            AzoogleCreative.destroy_all(["sub_id = ? AND azoogle_offer_id = ?", referrer_code, offer.id])
        
            # Create Click URL
            AzoogleCreative.create(:creative_type => 'url', :sub_id => referrer_code, :azoogle_offer_id => offer.id, :data => new_offer.click_url)
        
            # Create other associated ads
            ['banner','html','flash'].each do |creative_type|
              new_offer.send(creative_type + '_creatives').each do |c|
                AzoogleCreative.create(:creative_type => creative_type, :sub_id => referrer_code, :azoogle_offer_id => offer.id, :data => c.data, :width => c.width, :height => c.height)
              end
            end
          end
        
          offer.reload
        end
      end
    end
    
    def populate_ads_for(referrer_code)
      init_offer_list!(referrer_code) if @az_account.offers.count < 1
      @az_account.offers.collect{|o| [o, o.creatives.count(:conditions => ['sub_id = ?', referrer_code])] }.each do |o|
        refresh_offer!(o[0], referrer_code, true)
      end
    end
    
    def refresh_offers(referrer_code,force=false)
      if force
        @az_account.offers.each do |o|
          refresh_offer!(o,referrer_code)
        end
      else
        @az_account.offers.find(:all, :conditions => ["updated_at < ?", (12.hours.ago - rand(10).minutes).to_s(:db)]).each do |o|
          refresh_offer!(o,referrer_code)
        end
      end
    end
    

    
  end
  
  class AzApiDriver
    SOAP_URL = 'https://login.azoogleads.com/soap/azads2_server.php'
    TRAFFIC_TYPE_IDS = {:email => 1, :display => 2, :search => 3, :popup => 4, :incentivized => 6}
    DEFAULT_TRAFFIC_TYPE = 2
    
    attr_reader :publisher_id, :login_hash
    
    def initialize(login_hash=nil)
      options = YAML.load_file("#{RAILS_ROOT}/config/azoogle.yml")
      @publisher_id = options[:publisher_id]
      @login = options[:login]
      @password = options[:password]
      
      raise "missing auth data" unless @publisher_id && @login && @password

      @driver = SOAP::RPC::Driver.new(SOAP_URL)
      add_soap_methods!
      
      authenticate if (login_hash.nil?) unless (login_hash == false)
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
          authenticate if @login_hash.nil?
          puts "soap calling getList"
          emails = @driver.getList(@login_hash,@publisher_id,offer_id,separator)
          return nil unless emails.is_a?(String)
          return emails.split(separator)
        end

        def isSuppressed(email_address)
          authenticate if @login_hash.nil?
          puts "soap calling isSuppressed"
          result = @driver.isSuppressed(@login_hash,@publisher_id,offer_id,email_address)
          return (result == '1' ? true : false)
        end

        def getSubHits(offer_id,start_date=nil,end_date=nil,type_id=nil,sales_only=nil)
          authenticate if @login_hash.nil?
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
          authenticate if @login_hash.nil?
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
          authenticate if @login_hash.nil?
          puts "soap calling offerDetails"
          type_id ||= 2
          results = @driver.offerDetails(@login_hash, @publisher_id, offer_id, type_id, sub_id, keyword_delimeter)
          return nil if results.nil?
          return nil if results[0].open_date == "0000-00-00"
          unless results.empty?
            return nil if results[0].is_a?(String)
            case type_id
              # TODO: implement other traffic types
              when 2
                the_offer = AzWebOffer.new
                the_offer.banner_creatives = results[0].banner_creatives if results[0].respond_to?("banner_creatives")
                the_offer.html_creatives = results[0].html_creatives if results[0].respond_to?("html_creatives")
                the_offer.flash_creatives = results[0].flash_creatives if results[0].respond_to?("flash_creatives")
            end
            the_offer.offer_id = offer_id
            the_offer.title = results[0].title
            the_offer.description = results[0].description
            the_offer.open_date = Date.parse(results[0].open_date)
            the_offer.expiry_date = Date.parse(results[0].expiry_date)
            the_offer.amount = results[0].amount        
            the_offer.categories = results[0].categories.collect{|c| c.downcase} if results[0].respond_to?("categories")
            # the_offer.click_url = generateClickUrl(offer_id, type_id, sub_id)
          else
            the_offer = nil
          end
          # puts the_offer.inspect
          return the_offer
        rescue
          puts "Error parsing offer details for offer => #{offer_id}"
          # puts results.inspect
          return nil
        end

        def listOffers
          authenticate if @login_hash.nil?
          puts "soap calling listOffers"
          result = @driver.listOffers(@login_hash, @publisher_id)
          return result
        end

        def generateClickUrl(offer_id, type_id=DEFAULT_TRAFFIC_TYPE, sub_id=nil)
          authenticate if @login_hash.nil?
          puts "soap calling generateClickUrl"
          result = @driver.generateClickUrl(@login_hash, @publisher_id, offer_id, type_id, sub_id)
          if result.match(/^http/i)
            return result
          else
            return nil
          end
        end
    ####### END SOAP API METHODS
    
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
  end
  
  class AzOffer
    attr_accessor :offer_id, :title, :description, :open_date,  :expiry_date, :notices, :amount, :categories
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
  
  class AzWebOffer < AzOffer
      attr_accessor :banner_creatives, :html_creatives, :flash_creatives, :click_url
      
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
      
      private
      
      def init_offer_arrays!
        super
        @banner_creatives = []
        @html_creatives = []
        @flash_creatives = []
        @click_urls = []
      end
      
      def populate_creatives!(creative_array,data_array)
        data_array.each do |ad_data|
          ad = AzCreative.new(ad_data.width, ad_data.height, ad_data.data)
          creative_array << ad unless ad.data.nil?
        end
      end
  end
  
  class AzCreative
    attr_accessor :width, :height, :data
    def initialize(ad_width, ad_height, ad_data)
      @width = ad_width.to_i
      @height = ad_height.to_i
      @data = ad_data
    end
  end
  
end