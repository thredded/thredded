class DropUserTopicReads < ActiveRecord::Migration
  def up
    drop_table 'thredded_user_topic_reads'
  end

  def down
    create_table :thredded_user_topic_reads do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :post_id, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :page, default: 1, null: false
      t.timestamps
    end

    add_index :thredded_user_topic_reads, :topic_id
    add_index :thredded_user_topic_reads, [:user_id, :topic_id], unique: true
  end
end
