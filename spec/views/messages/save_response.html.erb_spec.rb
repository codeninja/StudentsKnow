require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/save_response" do
  before(:each) do
    render 'messages/save_response'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', /Find me in app\/views\/messages\/save_response/)
  end
end
