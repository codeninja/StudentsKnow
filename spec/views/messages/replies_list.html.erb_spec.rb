require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/replies_list" do
  before(:each) do
    render 'messages/replies_list'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', /Find me in app\/views\/messages\/replies_list/)
  end
end
