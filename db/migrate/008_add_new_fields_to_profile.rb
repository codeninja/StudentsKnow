class AddNewFieldsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :classes, :text
    add_column :profiles, :website, :string
    add_column :profiles, :city, :string
  end

  def self.down
    remove_column :profiles, :classes
    remove_column :profiles, :website
    remove_column :profiles, :city
  end
end
