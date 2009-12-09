class AddProfileOptIn < ActiveRecord::Migration
  def self.up
    add_column :profiles, :optin, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :optin
  end
end
