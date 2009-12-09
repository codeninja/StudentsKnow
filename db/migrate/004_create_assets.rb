class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :parent_id, :size, :width, :height, :attachable_id
      t.string :content_type, :filename, :thumbnail, :checksum, :attachable_type
      t.boolean :is_duplicate, :default => false
      t.timestamps
    end
    add_index :assets, :parent_id
    add_index :assets, :checksum
    add_index :assets, [:attachable_id, :attachable_type]
  end

  def self.down
    drop_table :assets
  end
end
