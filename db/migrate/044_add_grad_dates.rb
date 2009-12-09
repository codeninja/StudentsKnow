class AddGradDates < ActiveRecord::Migration
  def self.up
    add_column :profiles, :grad_start, :date
    add_column :profiles, :grad_grad, :date
  end

  def self.down
    remove_column :profiles, :grad_start
    remove_column :profiles, :grad_grad
  end
end
