namespace :misc do
  namespace :generator do
	
    desc "Create Random Info for User Accounts"
    task :accounts => :environment do
      include Markhov

      maxusers = ENV["users"].to_i || 10
      corpus = "#{RAILS_ROOT}/config/lorem-small.txt"

      puts "Creating #{maxusers} Accounts"
      puts "  - (Loading Name Generator)"
      p = PersonGen.new("#{RAILS_ROOT}/config/names.yml")

      universities = Array.new(20) do
        gender = [:male,:female][rand(2).to_i]
        name = p.fullname(gender,3)
        name.split(" ").last.capitalize + " University"
      end
      
      
      unless User.find_by_login("testuser")
        puts " * Creating Test User"
        login = "testuser"
        password = "12345"
        firstname = "TestFirst"
        middlename = "TestMiddle"
        lastname = "TestLast"
        u = User.create(
          :login => login,
          :password => password,
          :password_confirmation => password,
          :email => login + "@localhost.com",
          :name_first => firstname,
          :name_middle => middlename,
          :name_last => lastname
        )
        u.activated_at = Time.now
        u.save
        u.create_profile(
          :country => "US",
          :state => "TX",
          :zip => "78701",
          :gender => "M",
          :university => universities[rand(universities.size)],
          :dob => (Date.today - 25.years - 1.month), 
          :start => Date.today - 5.years - 1.month, 
          :graduation => Date.today - 1.year - 1.month, 
          :receive_emails => true, 
          :email_sent => true, 
          :over_13 => true, 
          :terms => true
        )
      end
      


      maxusers.times do |index|
        gender = [:male,:female][rand(2).to_i]
        name = p.fullname(gender,3)
        firstname = name.split(" ")[0].capitalize
        middlename = name.split(" ")[1].capitalize
        lastname = name.split(" ")[2].capitalize
        login = firstname.downcase + rand(1000).to_s
        email = login + "@localhost.com"
        password = "foobar"
        age = rand(25) + 20
        start_school_at_age = [17,(age - 5 - rand(5))].max
        start_school = Date.today - (age - start_school_at_age).years - 1.month
        # Create User
        puts " * Creating User #{index + 1} of #{maxusers} => #{login}"
        u = User.create(
          :login => login,
          :password => password,
          :password_confirmation => password,
          :email => login + "@localhost.com",
          :name_first => firstname,
          :name_middle => middlename,
          :name_last => lastname
        )
        u.activated_at = Time.now
        u.save

        # Create Profile
        puts "  - Creating Profile for #{login}"
        u.create_profile(
          :country => "US",
          :state => "TX",
          :zip => "78701",
          :gender => "M",
          :university => universities[rand(universities.size)],
          :dob => Date.today - age.years, 
          :start => start_school, 
          :graduation => start_school + 4.years, 
          :receive_emails => true, 
          :email_sent => true, 
          :over_13 => true, 
          :terms => true
        )
        u.activate
        upload_profile_pic(u)
      end
    end

    desc "Create Videos"
    task :videos => :environment do
      include Markhov
      corpus = "#{RAILS_ROOT}/config/lorem.txt"
      s = SentenceGen.new(corpus)
      p = PersonGen.new("#{RAILS_ROOT}/config/names.yml")

      professors = Array.new(20) do
        gender = [:male,:female][rand(2).to_i]
        pname = p.fullname(gender,(rand(2) + 1))
        "Dr. #{pname}" 
      end

      categories = Tag.find(:all, :conditions => 'is_category = 1').collect{|t| t.name}
      
      users = User.find(:all)

      users.each do |user|
        puts "\n\n"
        puts "* Uploading Videos for #{user.login}..."
        (rand(3) + 2).times do |index|
          tags = s.sentence(2).gsub(/[^a-z ]/i,'').split(" ").uniq[0..rand(3)]
          professor = professors[rand(professors.size)]
          options = {
            :name => s.sentence(1)[0..39],
            :description => s.sentence(rand(2) + 1)[0..99],
            :tagnames => tags.join(', '),
            :subject => tags[rand(tags.size)],
            :professor => professor,
            :book_title => "Stuff According to #{professor}",
            :book_author => professors[rand(professors.size)],
            :chapter => rand(100),
            :isbn => sprintf("%03d-%d-%02d-%06d-%d",rand(1000),rand(10),rand(100),rand(1000000),rand(10)),
            :category => categories[rand(categories.size)]
          }
          puts "   - Video #{index + 1}"
          upload_video(user,options)
        end
      end
    end
   
    desc "Create Pageviews for videos"
    task :hits => :environment do
      Video.find(:all).each{|v| rand(100).times{v.hit} }
    end
   
    desc "Mark Favorites"
    task :favorites => :environment do
      User.find(:all).each do |user|
        Favorite.find(:all, :conditions => ['user_id = ?', user.id]).each{|f| f.destroy}
        vids = Video.find(:all, :limit => rand(10), :order => 'RAND()') + []
        vids.each do |vid|
          vid.is_liked_by!(user)
        end  
      end
    end

    desc "Messages"
    task :messages => :environment do
      include Markhov
      corpus = "#{RAILS_ROOT}/config/lorem.txt"
      s = SentenceGen.new(corpus)
      puts "Creating Messages for..."
      users = User.find(:all)
      users.each do |user| 
        puts "  - #{user.login}"
        Tag.find(:all, :conditions => 'is_category = 1').each do |category|
          puts "   * #{category.name}"
          3.times do |index|
            m = Message.new(:user_id => user.id, :topic => s.sentence(1), :data => s.sentence(rand(2) + 1), :category => category.name)
            unless m.save
              puts m.errors.inspect
              raise "error"
            end
            m.tagnames = category.name
            m.save
          end
        end
      end
      users.each do |user|
        Message.find(:all).each do |message|
          c = message.comments.new(:user_id => user.id, :title => 'n', :comment => s.sentence(rand(2) + 1))
          c.save
          message.save
        end
      end
    end

    desc "Kitchen Sink"
    task :all => [:accounts, :videos, :favorites, :hits] do
      # nothing really
    end
    
  end
end


def upload_video(user,options)
  require RAILS_ROOT+"/vendor/rails/actionpack/lib/action_controller/integration.rb" 
  vid_path = ENV["VID_PATH"] || (RAILS_ROOT + "/test/data_for_random/vid")
  raise "Please specify a video path: VID_PATH=path" if vid_path.empty?
  target_model = "video"
  videos = Dir.glob(vid_path+"/*")
  login_as(user)

  vid = videos[rand(videos.size)]
  puts "   - Uploading #{vid}..."
  
  video = user.videos.create(
    :fileupload => ActionController::TestUploadedFile.new(vid,'video/mpeg'),
    :name => options[:name],
    :description => options[:description],
    :tagnames => options[:tagnames],
    :subject => options[:subject],
    :professor => options[:professor],
    :class_number => options[:class_num],
    :book_title => options[:book_title],
    :book_author => options[:book_author],
    :chapter => options[:chapter],
    :isbn => options[:isbn],
    :category => options[:category])
  video.tag_list = [%w{test1 test2 test3 test4}[rand(4)]]
  video.save        
#  sleeptime = 10        
#  puts "* PLEASE WAIT:  Waiting at least #{sleeptime} seconds for upload and conversion..."        
#  sleep(sleeptime)
end

def upload_profile_pic(user)
  require RAILS_ROOT+"/vendor/rails/actionpack/lib/action_controller/integration.rb" 
  img_path = ENV["IMG_PATH"] || (RAILS_ROOT + "/test/data_for_random/img")
  raise "Please specify an image path: IMG_PATH=path" if img_path.empty?
  imgs = Dir.glob(img_path + "/*")
  img = imgs[rand(imgs.size)]
  user.images.create(:fileupload => ActionController::TestUploadedFile.new(img,'image/jpeg'), :profile_pic => true)
end

def login_as(user)
  @request    = ActionController::TestRequest.new
  @request.session[:user] = user
end


