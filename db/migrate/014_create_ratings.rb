class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :value, :default => 3
      t.integer :user_id, :rateable_id
      t.string :rateable_type
      t.timestamps
    end
    add_index :ratings, :user_id
    add_index :ratings, [:rateable_id, :rateable_type]
  end

  def self.down
    drop_table :ratings
  end
end
