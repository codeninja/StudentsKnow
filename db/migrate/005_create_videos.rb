class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.integer :user_id
      t.string :name, :description
      t.string :university, :class_number, :professor, :subject, :book_title, :book_author, :chapter, :isbn
      t.timestamps
    end
    add_index :videos, :user_id
  end
  
  def self.down
    drop_table :videos
  end
end
