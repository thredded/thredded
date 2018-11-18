# frozen_string_literal: true

require 'thredded/base_migration'

# rubocop:disable Metrics/MethodLength
class UpgradeV08ToV09 < Thredded::BaseMigration
  def up
    create_table :thredded_notifications_for_private_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id notifier_key],
              name: 'thredded_notifications_for_private_topics_unique', unique: true
    end
    create_table :thredded_notifications_for_followed_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id notifier_key],
              name: 'thredded_notifications_for_followed_topics_unique', unique: true
    end
    create_table :thredded_messageboard_notifications_for_followed_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.references :messageboard, null: false, index: false, type: column_type(:thredded_messageboards, :id)
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id messageboard_id notifier_key],
              name: 'thredded_messageboard_notifications_for_followed_topics_unique', unique: true
    end

    Thredded::UserPreference.all.each do |pref|
      pref.notifications_for_private_topics.create!(notifier_key: 'email', enabled: pref.notify_on_message)
      pref.notifications_for_followed_topics.create!(notifier_key: 'email', enabled: pref.followed_topic_emails)
    end
    Thredded::UserMessageboardPreference.pluck(:user_id, :messageboard_id, :followed_topic_emails)
      .each do |user_id, messageboard_id, emails|
      Thredded::UserPreference.find_or_create_by!(user_id: user_id)
      Thredded::MessageboardNotificationsForFollowedTopics.create!(
        user_id: user_id,
        messageboard_id: messageboard_id,
        notifier_key: 'email',
        enabled: emails
      )
    end

    remove_column :thredded_user_preferences, :notify_on_message
    remove_column :thredded_user_preferences, :followed_topic_emails
    remove_column :thredded_user_messageboard_preferences, :followed_topic_emails
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
# rubocop:enable Metrics/MethodLength
