class RemoveUnusedIndexes < ActiveRecord::Migration
  def change
    remove_index :thredded_user_topic_reads, column: :post_id
    remove_index :thredded_user_topic_reads, column: :page
    remove_index :thredded_user_topic_reads, column: :user_id
    remove_index :thredded_user_topic_reads, column: :posts_count
    remove_index :thredded_topics, column: :last_user_id
  end
end
