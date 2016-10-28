class AddNotificationsForFollowedTopics < ActiveRecord::Migration
  def change
    add_column :thredded_user_preferences, :notifications_for_followed_topics, :string, default: ''
    add_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics, :string, default: ''
    add_column :thredded_user_preferences, :notifications_for_private_topics, :string, default: ''
    add_column :thredded_user_messageboard_preferences, :notifications_for_private_topics, :string, default: ''
    remove_column :thredded_user_preferences, :followed_topic_emails
    remove_column :thredded_user_messageboard_preferences, :followed_topic_emails
    remove_column :thredded_user_preferences, :notify_on_message
  end
end
