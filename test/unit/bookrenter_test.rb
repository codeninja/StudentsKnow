require File.dirname(__FILE__) + '/../test_helper'

require "lib/bookrenter.rb"

class BookRenterTest < Test::Unit::TestCase
  
  def setup
    @b = BookRenter::Search
    @isbn13 = "9780805371468"
    @isbn10 = "080537146X"
    @invalid_isbn = '0000'
    @unknown_isbn = "0907861598"
  end
  
  def test_search_init
  end
  
  # This is now a private method  
  # def test_search_get_xml
  #   assert @isbn13 != @isbn10
  #   data10 = @b.instance.get_xml(@isbn10)
  #   data13 = @b.instance.get_xml(@isbn13)
  #   assert data10 == data13
  # end  
  
  def test_search_parse
    br = @b.instance.get(@isbn10)
    assert br.is_a?(BookRenter::BookResult)
    assert br.error.nil?
  end
  
  def test_search_invalid
    br = @b.instance.get(@invalid_isbn)
    assert br.is_a?(BookRenter::BookResult)
    assert br.error == 'invalidISBN'
  end
  
  def test_search_unknown
    br = @b.instance.get(@unknown_isbn)
    assert br.is_a?(BookRenter::BookResult)
    assert br.error = 'bookNotFound'
  end
  
  def test_full_detail
    fd = BookRenter::FullDetail.new(@isbn13)
    assert (not fd.nil?)
    assert (not fd.data.nil?)
  end
  
  def test_search_with_detail
    br = @b.instance.get(@isbn13,{},true)
    assert br.is_a?(BookRenter::BookResult)
    assert br.error.nil?
    assert br.image_url.is_a?(String)
  end
  
end