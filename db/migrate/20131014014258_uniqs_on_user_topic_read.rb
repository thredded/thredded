class UniqsOnUserTopicRead < ActiveRecord::Migration
  def up
    add_index :thredded_user_topic_reads, [:user_id, :topic_id], unique: true
  end

  def down
    remove_index :thredded_user_topic_reads, [:user_id, :topic_id]
  end
end
