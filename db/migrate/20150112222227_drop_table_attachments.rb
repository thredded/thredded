class DropTableAttachments < ActiveRecord::Migration
  def up
    drop_table :thredded_attachments
  end

  def down
    create_table :thredded_attachments do |t|
      t.string :attachment
      t.string :content_type
      t.integer :file_size
      t.integer :post_id

      t.timestamps
    end

    add_index :thredded_attachments, :post_id
  end
end
