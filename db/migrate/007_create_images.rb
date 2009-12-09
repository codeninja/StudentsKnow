class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :user_id
      t.string :description
      t.boolean :profile_pic, :default => false
      t.timestamps
    end
    add_index :images, :user_id
  end

  def self.down
    drop_table :images
  end
end
