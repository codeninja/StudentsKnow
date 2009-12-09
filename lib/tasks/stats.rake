namespace :stats do
  namespace :users do
    
    desc "User Accounts"
    task :list => :environment do
      User.find(:all, :include => :videos).each do |user|
          puts [ user.login, 
                 user.email, 
                 "#{user.name_first} #{user.name_last}", 
                 user.created_at.to_s(:long),
                 user.videos.compact.select{|v| v.status == 2 if v.videoasset}.size].join("\t")
      end
    end
  end
end