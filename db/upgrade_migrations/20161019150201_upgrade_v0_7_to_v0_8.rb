# frozen_string_literal: true
class UpgradeV07ToV08 < ActiveRecord::Migration
  def change
    add_column :thredded_user_preferences, :followed_topic_emails, :boolean, default: true, null: false
    add_column :thredded_user_messageboard_preferences, :followed_topic_emails, :boolean, default: true, null: false
    rename_column :thredded_user_preferences, :auto_follow_topics, :follow_topics_on_mention
    rename_column :thredded_user_messageboard_preferences, :auto_follow_topics, :follow_topics_on_mention
  end
end
