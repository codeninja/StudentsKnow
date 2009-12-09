class AddCareerServicesCat < ActiveRecord::Migration
  def self.up
    Tag.create(:name => "career-services", :description => 'Career Services', :is_category => true)
    Tag.find(:first, :conditions => "name LIKE '%site-feedback%'").destroy
    Tag.find(:all).each{|t| t.name = t.name.downcase; t.save}
  end

  def self.down
  end
end
