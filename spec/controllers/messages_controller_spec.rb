require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  
    fixtures :messages, :users, :comments, :tags
    controller_name :messages
    integrate_views

  
  specify "should be a MessagesController" do
         controller.should be_an_instance_of(MessagesController)
  end
  
  
  specify "shouldn't create message if not logged in" do
     logout
     prev = Message.count
     post :remote_save_message, :message => { :topic => "topic", :data => "data"}, :user_id => nil
     after = Message.count
     assert_equal(prev,after)
     response.should be_success   
  end
  
  specify "should create message" do
     prev = Message.count
     login_as :users_004
     post :remote_save_message, :message => { :topic => "topic", :data => "data"} , :user_id => users(:users_004).id, :id => tags(:tags_001).id
     after = Message.count
     assert_equal(prev + 1,after)
     response.should be_success   
  end

  
   specify "should fail with no data message" do
     prev = Message.count
     login_as :users_004
     post :remote_save_message, :message => { :topic => "topic"} , :user_id => users(:users_004).id, :id => tags(:tags_001).id
     after = Message.count
     assert_equal(prev,after)
     response.should be_success   
   
     assigns(:message).errors.on(:data).should ==  "can't be blank"
  end
  
  
  specify "should fail with no topic message" do
     prev = Message.count
     login_as :users_004
     post :remote_save_message, :message => { :data => "data"} , :user_id => users(:users_004).id, :id => tags(:tags_001).id
     after = Message.count
     assert_equal(prev,after)
     response.should be_success   
     assigns(:message).errors.on(:topic).should ==  "can't be blank"
  end
  
  specify "should fail with no user message" do
     prev = Message.count
     login_as :users_004
     post :remote_save_message, :message => { :data => "data", :topic => "topic"} , :id => tags(:tags_001).id
     after = Message.count
     assert_equal(prev,after)
     response.should be_success   
     assigns(:message).errors.on(:user_id).should ==  "can't be blank"
  end
  
   specify "should be able to post a reply" do
     prev = Comment.count
     login_as :users_004
     post :replies_list, :id => messages(:messages_001).id, :comment => {:title => "new comment", :comment => "comment text", :user_id => users(:users_004).id}
     after = Comment.count
     assert_equal(prev+1, after)
     response.should redirect_to(replies_list_path)
     
   end
   
   specify "should not be able to post a reply with mising title" do
     prev = Comment.count
     login_as :users_004
     post :replies_list, :id => messages(:messages_001).id, :comment => {:title => nil, :comment => "comment text", :user_id => users(:users_004).id}
     after = Comment.count
     assert_equal(prev, after)
     assigns(:comment).errors.on(:title).should ==  "can't be blank"
   end
   
  specify "should not be able to post a reply with mising comment" do
     prev = Comment.count
     login_as :users_004
     post :replies_list, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => nil, :user_id => users(:users_004).id}
     after = Comment.count
     assert_equal(prev, after)
     assigns(:comment).errors.on(:comment).should ==  "can't be blank"
   end
   
    
  specify "should not be able to post a reply unless logged in" do
     prev = Comment.count
     post :replies_list, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => nil, :user_id => users(:users_004).id}
     after = Comment.count
     assert_equal(prev, after)
     response.should redirect_to(login_path)
   end
  
  specify "should be able to show a reply" do
    get :show_reply, :id => comments(:comments_001).id
    response.should be_success 
  end
  
   specify "should be able to save response" do
    login_as :users_004
    prev = Comment.count
    post :save_response, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => "comment", :user_id => users(:users_004).id}
    after = Comment.count
    assert_equal(prev+1, after)
    response.should redirect_to(replies_list_path)
  end
  
  specify "should not be able to save response with missing data" do
    login_as :users_004
    prev = Comment.count
    post :save_response, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => nil, :user_id => users(:users_004).id}
    after = Comment.count
    assert_equal(prev, after)
  end
  
   specify "but when not logged in should redirect to login" do
    prev = Comment.count
    post :save_response, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => "comment", :user_id => users(:users_004).id}
    after = Comment.count
    assert_equal(prev, after)
    response.should be_redirect
  end
  
  specify "should be able to save response" do
    login_as :users_004
    prev = Comment.count
    post :remote_save_response, :id => messages(:messages_001).id, :comment => {:title => "title", :comment => "comment"} , :user_id => users(:users_004).id
    after = Comment.count
    assert_equal(prev+1, after)
  end
  
  specify "should not be able to save response" do
    login_as :users_004
    prev = Comment.count
    post :remote_save_response, :id => messages(:messages_001).id, :comment => {:title => nil, :comment => "comment"} , :user_id => users(:users_004).id
    after = Comment.count
    assert_equal(prev, after)
  end
  
  specify "should be able to load create message" do
    login_as :users_004
    prev = Comment.count
    post :remote_create_message, :id => tags(:tags_001).id
    after = Comment.count
    assert_equal(prev, after)
  end
  
 
  specify "call remote paginate" do
    post :remote_paginate, :cat_id => tags(:tags_001).id
    response.should be_success
  end
  
  

  
  
  
  
  
  
  

  #Delete these examples and add some real ones
  it "should use MessagesController" do
    controller.should be_an_instance_of(MessagesController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
 



  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
  



  describe "GET 'replies_list'" do
    it "should be successful" do
      get 'replies_list', :id => messages(:messages_001).id
      response.should be_success
    end
  end

  describe "POST 'search'" do
    it "should be successful" do
      post 'search', :message_search => {:item => "aaa"}
      response.should be_success
    end
  end
end
