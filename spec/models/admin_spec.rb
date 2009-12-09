require File.dirname(__FILE__) + '/../spec_helper'

describe Admin do
  before(:each) do
    @admin = Admin.new
  end

  it "should be valid" do
    @admin.should be_valid
  end
end
