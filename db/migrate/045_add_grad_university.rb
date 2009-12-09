class AddGradUniversity < ActiveRecord::Migration
  def self.up
    add_column :profiles, :grad_university, :string
  end

  def self.down
    remove_column :profiles, :grad_university
  end
end
