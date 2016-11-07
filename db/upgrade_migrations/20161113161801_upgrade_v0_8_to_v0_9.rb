# frozen_string_literal: true
class UpgradeV08ToV09 < ActiveRecord::Migration
  def up
    create_table :thredded_notifications_for_private_topics do |t|
      t.integer :user_id, null: false
      t.string :notifier_key, null: false
      t.boolean :wants, default: true, null: false
    end
    create_table :thredded_notifications_for_followed_topics do |t|
      t.integer :user_id, null: false
      t.string :notifier_key, null: false
      t.boolean :wants, default: true, null: false
    end
    create_table :thredded_messageboard_notifications_for_followed_topics do |t|
      t.integer :user_id, null: false
      t.integer :messageboard_id, null: false
      t.string :notifier_key, null: false
      t.boolean :wants, default: true, null: false
    end

    Thredded::UserPreference.includes(:user).each do |pref|
      pref.user.create_notifications_for_private_topics(notifier_key: 'email', wants: pref.notify_on_message)
      pref.user.create_notifications_for_followed_topics(notifier_key: 'email', wants: pref.followed_topic_emails)
    end
    Thredded::MessageboardUserPreference.includes(:user).each do |pref|
      Thredded::MessageboardNotificationsForFollowedTopics.create(
        user_id: pref.user_id,
        messageboard_id: pref.messageboard_id,
        notifier_key: 'email',
        wants: pref.notify_on_message
      )
    end

    remove_column :thredded_user_preferences, :notify_on_message
    remove_column :thredded_user_preferences, :followed_topic_emails
    remove_column :thredded_messageboard_user_preferences, :followed_topic_emails
  end

  def down
    add_column :thredded_user_preferences, :notify_on_message, :boolean, default: true, null: false
    add_column :thredded_user_preferences, :followed_topic_emails, :boolean, default: true, null: false
    add_column :thredded_user_messageboard_preferences, :followed_topic_emails, :boolean, default: true, null: false

    drop_table :thredded_messageboard_notifications_for_followed_topics
    drop_table :thredded_notifications_for_followed_topics
    drop_table :thredded_notifications_for_private_topics
  end
end
