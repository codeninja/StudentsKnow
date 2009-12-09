class CreateAdpages < ActiveRecord::Migration
  def self.up
    create_table :adpages do |t|
      t.string :name
    end
    add_index :adpages, :name
    
    ["home", "video", "mess_board_left", "mess_board_bottom",  "mess_board_right", "mess_board_right bottom"].each do |page|
      Adpage.create(:name => page)
    end
    
  end

  def self.down
    drop_table :adpages
  end
end
