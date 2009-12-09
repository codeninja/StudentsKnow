class AddApprovesBitToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :approved, :boolean, :default=> false
  end

  def self.down
    remove_column :videos, :approved
  end
end
