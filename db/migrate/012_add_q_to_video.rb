class AddQToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :in_q, :boolean, :default => false
    add_index :videos, :in_q
  end

  def self.down
    remove_index :videos, :in_q
    remove_column :videos, :in_q
  end
end
