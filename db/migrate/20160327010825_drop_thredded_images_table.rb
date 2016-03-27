class DropThreddedImagesTable < ActiveRecord::Migration
  def up
    drop_table :thredded_images
    remove_column :thredded_messageboards, :private_topics_count
  end

  def down
    add_column :thredded_messageboards, :private_topics_count, :integer, default: 0
    create_table :thredded_images do |t|
      t.integer :post_id
      t.integer :width
      t.integer :height
      t.string  :orientation
      t.timestamps
    end
  end
end
