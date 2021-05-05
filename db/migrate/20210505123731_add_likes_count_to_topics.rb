class AddLikesCountToTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :likes_count, :integer, default: 0
  end
end
