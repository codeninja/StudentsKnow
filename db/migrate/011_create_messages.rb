class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :user_id, :null => false
      t.string :topic
      t.text :data
      t.timestamps
    end
     add_index :messages, :user_id
  end

  def self.down
    drop_table :messages
  end
end
