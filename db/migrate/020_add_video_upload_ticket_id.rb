class AddVideoUploadTicketId < ActiveRecord::Migration
  def self.up
    add_column :videos, :upload_ticket, :string
    add_column :assets, :upload_ticket, :string
    add_index :videos, :upload_ticket
    add_index :assets, :upload_ticket
  end

  def self.down
    remove_column :videos, :upload_ticket
    remove_column :assets, :upload_ticket
  end
end
