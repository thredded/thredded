class CreateThreddedPrivateTopics < ActiveRecord::Migration
  def change
    create_table :thredded_private_topics do |t|
      t.integer :user_id, null: false
      t.integer :last_user_id, null: false
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :messageboard_id, null: false
      t.integer :posts_count, default: 0
      t.string :hash_id, null: false

      t.timestamps
    end

    add_index :thredded_private_topics, :slug
    add_index :thredded_private_topics, :messageboard_id
    add_index :thredded_private_topics, :hash_id
  end
end
