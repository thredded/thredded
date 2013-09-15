class IndexNecessaryColumns < ActiveRecord::Migration
  def change
    add_index :thredded_attachments, :post_id
    add_index :thredded_categories, :messageboard_id
    add_index :thredded_images, :post_id
    add_index :thredded_post_notifications, :post_id
    add_index :thredded_messageboards, :slug

    add_index :thredded_posts, :user_id
    add_index :thredded_posts, :topic_id
    add_index :thredded_posts, :messageboard_id

    add_index :thredded_private_users, :private_topic_id
    add_index :thredded_private_users, :user_id

    add_index :thredded_topic_categories, :topic_id
    add_index :thredded_topic_categories, :category_id

    add_index :thredded_topics, :user_id
    add_index :thredded_topics, :last_user_id
    add_index :thredded_topics, :messageboard_id
    add_index :thredded_topics, :hash_id
  end
end
