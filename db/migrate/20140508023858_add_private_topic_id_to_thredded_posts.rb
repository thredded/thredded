class AddPrivateTopicIdToThreddedPosts < ActiveRecord::Migration
  def change
    add_column :thredded_posts, :private_topic_id, :integer
  end
end
