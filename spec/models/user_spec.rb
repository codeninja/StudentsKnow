require File.dirname(__FILE__) + '/../spec_helper'

describe User, "with fixtures loaded" do
	fixtures :users

  it "should have a non-empty collection of users" do
    User.find(:all).should_not be_empty
  end

  it "should have six records" do
    User.should have(6).records
  end

  
  it "should find an activated user" do
	 user = User.find(:first, :conditions => "activated_at = '2007-06-12 20:23:51'")
         user.should eql(users(:users_003))
  end


  it "should find an existing user" do
	  user = User.find(users(:users_001).id)
	  user.should eql(users(:users_001))
  end

end
