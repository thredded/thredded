class AddNotificationsForFollowedTopics < ActiveRecord::Migration
  def change
    add_column :thredded_user_preferences, :notifications_for_followed_topics, :string, default: ''
    add_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics, :string, default: ''
    add_column :thredded_user_preferences, :notifications_for_private_topics, :string, default: ''
    add_column :thredded_user_messageboard_preferences, :notifications_for_private_topics, :string, default: ''
  end
end
