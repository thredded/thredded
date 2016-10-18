# frozen_string_literal: true
class UpgradeV07ToV08 < ActiveRecord::Migration
  def change
    add_column :thredded_user_preferences, :followed_topic_emails, :boolean, default: true, null: false
    add_column :thredded_user_messageboard_preferences, :followed_topic_emails, :boolean, default: true, null: false
    rename_column :thredded_user_preferences, :notify_on_mention, :auto_follow_topics
    rename_column :thredded_user_messageboard_preferences, :notify_on_mention, :auto_follow_topics
  end
end
