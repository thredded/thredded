# frozen_string_literal: true
class UpgradeV07ToV08 < ActiveRecord::Migration
  def up
    add_column :thredded_user_preferences, :notifications_for_followed_topics, :string, default: '', null: false
    add_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics, :string, default: '',
                                                                                                     null: false
    add_column :thredded_user_preferences, :notifications_for_private_topics, :string, default: '', null: false
    rename_column :thredded_user_preferences, :notify_on_mention, :follow_topics_on_mention
    rename_column :thredded_user_messageboard_preferences, :notify_on_mention, :follow_topics_on_mention
    change_column :thredded_messageboards, :name, :string, limit: 191

    Thredded::UserPreference.reset_column_information
    Thredded::UserPreference.where(notify_on_message: false)
      .update_all(['notifications_for_private_topics =?', 'email'])

    remove_column :thredded_user_preferences, :notify_on_message
  end

  def down
    add_column :thredded_user_preferences, :notify_on_message, :boolean, default: true, null: false

    change_column :thredded_messageboards, :name, :string, limit: 255
    rename_column :thredded_user_messageboard_preferences, :follow_topics_on_mention, :notify_on_mention
    rename_column :thredded_user_preferences, :follow_topics_on_mention, :notify_on_mention

    remove_column :thredded_user_preferences, :notifications_for_followed_topics
    remove_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics
    remove_column :thredded_user_preferences, :notifications_for_private_topics
  end
end
