class CreateKnowFeeds < ActiveRecord::Migration
  def self.up
    create_table :know_feeds do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
    add_index :know_feeds, :user_id
  end

  def self.down
    drop_table :know_feeds
  end
end
