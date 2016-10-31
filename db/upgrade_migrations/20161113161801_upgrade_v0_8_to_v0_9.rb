# frozen_string_literal: true
class UpgradeV08ToV09 < ActiveRecord::Migration
  def up
    add_column :thredded_user_preferences, :notifications_for_followed_topics, :string, default: '', null: false
    add_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics, :string, default: '',
      null: false
    add_column :thredded_user_preferences, :notifications_for_private_topics, :string, default: '', null: false

    Thredded::UserPreference.reset_column_information
    Thredded::UserPreference.where(notify_on_message: false)
      .update_all(['notifications_for_private_topics =?', 'email'])

    remove_column :thredded_user_preferences, :notify_on_message
  end

  def down
    add_column :thredded_user_preferences, :notify_on_message, :boolean, default: true, null: false

    # TODO: downgrade exisiting notify_on_message preferences before removing (really??)

    remove_column :thredded_user_preferences, :notifications_for_followed_topics
    remove_column :thredded_user_messageboard_preferences, :notifications_for_followed_topics
    remove_column :thredded_user_preferences, :notifications_for_private_topics
  end
end
