module BookRenter
  require 'yaml'
  require 'open-uri'
  require 'rexml/document'
  require 'rubygems'
  require 'scrapi'
  require 'singleton'
  

  # BookRenter API Module Search Class Usage:
  #
  # search = Bookrenter::Search
  #
  # search.instance.get(isbn,options={},extended_info=false) => BookResult
  class Search
    include Singleton
    
    CONFIG = "#{RAILS_ROOT}/config/bookrenter.yml"
    API_URL = "http://www.bookrenter.com/api/"
    HTML_CACHE_TTL = 43200     # seconds
    
    attr_reader :api_key, :api_version
    
    def initialize(config=CONFIG)
      init_html_cache
      load_config!(config)
    end
    
    # Returns an object with relevant attributes.  Pass true to the extended_info argument
    # to scrape additional info no available via the API.
    #
    # Options hash is available to override API query parameters or specify additional params
    #
    # Default options => {:action => 'fetch_book_info', :version => @api_version, :developer_key => @api_key, :book_details => 'y', :isbn => isbn}
    #
    # Usage:  search.instance.get(isbn,options={},extended_info=false) => BookResult
    def get(isbn,options={}, extended_info=false)
      clean_isbn = isbn.to_s.gsub(/[^0-9a-z]/i,'')
      book_result = parse(get_xml(clean_isbn, options))
      book_result = get_extended(book_result) if extended_info
      return book_result
      rescue
        return book_result
    end

    def run_query(url)
      expire_cache
      if (html = @cached_html[url]).nil?
        @cached_html[url] = html = open(url).read
      end
      return html
    end
    
    private
    
    def get_xml(isbn,options={})
      return run_query(build_query(isbn,options))
    end
    
    def expire_cache
      init_html_cache if ((Time.now - @cache_time > HTML_CACHE_TTL) || @cached_html.keys.size > 500)
    end
    
    def init_html_cache
      @cache_time = Time.now
      @cached_html = {}
    end
    
    def get_extended(book_result) 
      detail = FullDetail.new(book_result.isbn13).data
      if detail
        book_result.image_url = detail.image 
        book_result.description = detail.description
        book_result.pages = detail.pages
        book_result.weight = detail.weight
        book_result.height = detail.height
        book_result.width = detail.width
        book_result.depth = detail.depth
      end
      return book_result
    end
    
    def parse(data)
      parser = SearchParser.new(data)
      return parser.parse!
    end
    
    def build_query(isbn,in_options={})
      default_options = {:action => 'fetch_book_info', :version => @api_version, :developer_key => @api_key, :book_details => 'y', :isbn => isbn}
      options = default_options.merge(in_options)
      action = options[:action]
      options.delete(:action)
      url = API_URL + "#{action}?" + options.to_a.collect{|o| o.join('=')}.join('&')
      return url
    end
    
    def load_config!(config)
      raise "config file not found at #{config}" unless File.exist?(config)
      
      config_hash = YAML.load(File.read(config))
      raise "invalid configuration at #{config}" unless config_hash.is_a?(Hash)
      
      @api_key = config_hash[:key]
      @api_version = config_hash[:version]
    end
  end
  
  class FullDetail
    DETAIL_URL = "http://www.bookrenter.com/products/details/"
    Scraper::Base.parser :html_parser
      
    class SiteSearchScraper < Scraper::Base
      process "div#main_content div.fieldset h1 span.title", :title => :text
      process "div.book_details div#major_fields div.author span.value a", :author => :text
      process "div.book_details div#major_fields div.isbn_13 span.value", :isbn13 => :text
      process "div.book_details div#major_fields div.isbn_10 span.value", :isbn10 => :text
      process "div.book_details div.book_image_container div.hover_up img", :image => "@src"
      process "div.book_details div#minor_details div.publication_date span.value", :publication_date => :text
      process "div.book_details div#minor_details div.publisher span.value", :publisher => :text
      process "div.book_details div#minor_details div.language span.value", :language => :text
      process "div.book_details div#minor_details div.type span.value", :book_binding => :text
      process "div.book_details div#minor_details div.edition span.value", :edition => :text
      process "div.book_details div#minor_details div.minor_fields_block div.description span.value", :description => :text
      process "div.book_details div#minor_details div.number_of_pages span.value", :pages => :text
      process "div.book_details div#minor_details div.weight span.value", :weight => :text
      process "div.book_details div#minor_details div.height span.value", :height => :text
      process "div.book_details div#minor_details div.width span.value", :width => :text
      process "div.book_details div#minor_details div.depth span.value", :depth => :text
      
      result  :title, :author, :publisher, :publication_date, :book_binding, :edition, :language, 
              :isbn13, :isbn10, :image, :description, :pages, :weight, :height, :width, :depth
    end
    
    def initialize(isbn)
      clean_isbn = isbn.to_s.gsub(/[^0-9a-z]/i,'')
      # @html = open((DETAIL_URL + clean_isbn)).read
      @html = Search.instance.run_query(DETAIL_URL + clean_isbn)
      @data = nil
    end
    
    def data
      return (@data.nil? && (not @html.nil?) ? SiteSearchScraper.scrape(@html) : @data)
    end
  end
  

  
  class SearchParser
    attr_reader :error
    
    def initialize(xml_data)
      @xml = REXML::Document.new(xml_data)
      @error = nil
    end
    
    def parse!
      data = {}
      error_node = @xml.root.elements["error"]
      if error_node
        @error = error_node.text
        data[:error] = @error
      else
        book_node = @xml.root.elements["//response/book"]
        info_node = book_node.elements["info"]
        prices_node = book_node.elements["prices"]
        
        authors = []
        info_node.elements.each("authors/author"){|a| authors << a.text }
        data[:authors] = authors
        
        if prices_node
          rental_prices = []
          prices_node.elements.each("rental_price") do |p|
            if p.respond_to?("attributes['days']")
              rental_prices << "#{p.attributes['days']} Days: #{p.text}"
            else
              rental_prices << [p.attributes["days"], p.text]
            end
          end
          data[:rental_prices] = rental_prices.sort_by{|x| x.first.to_i}
          data[:purchase_price] = (f = prices_node.elements["purchase_price"]) ? f.text : nil
        end

        data[:availability] = (f = book_node.elements["availability"]) ? f.text : nil
        data[:isbn10] = (f = info_node.elements["isbn10"]) ? f.text : nil
        data[:isbn13] = (f = info_node.elements["isbn13"]) ? f.text : nil
        data[:title] = (f = info_node.elements["title"]) ? f.text : nil
        data[:book_binding] = (f = info_node.elements["book_binding"]) ? f.text : nil
        data[:publisher] = (f = info_node.elements["publisher"]) ? f.text : nil
        data[:publication_date] = (f = info_node.elements["publication_date"]) ? f.text : nil
        data[:lowest_shipping_price] = (f = book_node.elements["lowest_shipping_price"]) ? f.text : nil
        data[:url] = (f = book_node.elements["url"]) ? f.text : nil

      end

      return BookResult.new(data)
    end
    
  end
  
  class BookResult
    attr_accessor :isbn13, :isbn10, :title, :authors, :book_binding, :publisher, :publication_date, 
                  :purchase_price, :rental_prices, :lowest_shipping_price, :url, :availability, 
                  :error, :image_url, :description, :pages, :weight, :height, :width, :depth
                  
    def initialize(options)
      options.each_pair do |key,value|
        setter = key.to_s + '='
        if self.respond_to?(setter)
          self.send(setter,value)
        else
          raise "tried to set invalid BookResult attribute => #{key}"
        end
      end
      
    end
  end
  
  
  
end