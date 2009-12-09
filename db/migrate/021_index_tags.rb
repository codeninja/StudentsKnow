class IndexTags < ActiveRecord::Migration
  def self.up
    add_index :tags, :is_category
    add_index :tags, :name
  end

  def self.down
    remove_index :tags, :is_category
    remove_index :tags, :name
  end
end
