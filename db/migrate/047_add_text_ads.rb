class AddTextAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :display_text, :string, :default => ''
    Adpage.create(:name => "text_ad")
  end

  def self.down
    remove_column :ads, :display_text
    Adpage.destroy(:name => "text_ad")
  end
end
