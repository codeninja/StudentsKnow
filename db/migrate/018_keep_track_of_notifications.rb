class KeepTrackOfNotifications < ActiveRecord::Migration
  def self.up
     create_table :notifications, :force => true do |t|
       t.integer :uid
       t.timestamps
      end
  end

  def self.down
    drop_table :notifications
  end
end
