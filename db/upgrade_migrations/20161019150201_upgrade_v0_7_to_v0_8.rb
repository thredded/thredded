# frozen_string_literal: true
class UpgradeV07ToV08 < ActiveRecord::Migration
  def up
    add_column :thredded_user_preferences, :followed_topic_emails, :boolean, default: true, null: false
    add_column :thredded_user_messageboard_preferences, :followed_topic_emails, :boolean, default: true, null: false
    rename_column :thredded_user_preferences, :auto_follow_topics, :follow_topics_on_mention
    rename_column :thredded_user_messageboard_preferences, :auto_follow_topics, :follow_topics_on_mention
    change_column :thredded_messageboards, :name, :string, limit: 191
  end

  def down
    change_column :thredded_messageboards, :name, :string, limit: 255
    rename_column :thredded_user_messageboard_preferences, :follow_topics_on_mention, :auto_follow_topics
    rename_column :thredded_user_preferences, :follow_topics_on_mention, :auto_follow_topics
    remove_column :thredded_user_messageboard_preferences, :followed_topic_emails
    remove_column :thredded_user_preferences, :followed_topic_emails
  end
end
