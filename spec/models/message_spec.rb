require File.dirname(__FILE__) + '/../spec_helper'


describe Message, "with fixtures loaded" do
	fixtures :messages, :users

  it "should have a non-empty collection of messages" do
    Message.find(:all).should_not be_empty
  end

  it "should have six records" do
    Message.should have(6).records
  end


  it "should find an existing message" do
	  message = Message.find(messages(:messages_001).id)
	  message.should eql(messages(:messages_001))
  end

end