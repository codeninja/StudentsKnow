class ExtendCreativeData < ActiveRecord::Migration
  def self.up
    change_column :azoogle_creatives, :data, :text
  end

  def self.down
    change_column :azoogle_creatives, :data, :string
  end
end
