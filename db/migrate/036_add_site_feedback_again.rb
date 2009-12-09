class AddSiteFeedbackAgain < ActiveRecord::Migration
  def self.up
    Tag.create(:name => "Site-Feedback", :description => "User feedback about the site, comments, issues, etc", :is_category => true)
  end

  def self.down
    Tag.find(:first, :conditions => "name = 'Site Feedback'").destroy
  end
end
