# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/LineLength
class UpgradeV02ToV03 < ActiveRecord::Migration
  def up
    remove_index :thredded_notification_preferences, name: :index_thredded_notification_preferences_on_messageboard_id
    remove_index :thredded_notification_preferences, name: :index_thredded_notification_preferences_on_user_id
    rename_table :thredded_notification_preferences, :thredded_user_messageboard_preferences
    remove_column :thredded_user_messageboard_preferences, :notifications_for_private_topics
    change_column_null :thredded_user_messageboard_preferences, :notify_on_mention, false
    add_column :thredded_user_preferences, :notify_on_mention, :boolean, default: true, null: false
    add_column :thredded_user_preferences, :notify_on_message, :boolean, default: true, null: false
    add_index :thredded_user_messageboard_preferences, [:user_id, :messageboard_id], unique: true, name: :thredded_user_messageboard_preferences_user_id_messageboard_id
    remove_column :thredded_user_preferences, :time_zone
    remove_column :thredded_messageboards, :filter
    remove_column :thredded_posts, :filter
    remove_column :thredded_private_posts, :filter
    drop_table :thredded_user_topic_reads
    %i(topic private_topic).each do |topics_table|
      table_name = :"thredded_user_#{topics_table}_read_states"
      create_table table_name do |t|
        t.integer :user_id, null: false
        t.integer :postable_id, null: false
        t.integer :page, default: 1, null: false
        t.timestamp :read_at, null: false
      end
      add_index table_name, [:user_id, :postable_id], name: :"#{table_name}_user_postable", unique: true
    end
    remove_column :thredded_private_users, :read
    remove_index :thredded_private_users, name: :index_thredded_private_users_on_read
  end

  def down
    add_column :thredded_private_users, :read, :boolean, default: false
    add_index :thredded_private_users, :read, name: :index_thredded_private_users_on_read
    drop_table :thredded_user_topic_read_states
    drop_table :thredded_user_private_topic_read_states
    create_table :thredded_user_topic_reads do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :post_id, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :page, default: 1, null: false
      t.timestamps null: false
    end
    add_index :thredded_user_topic_reads, [:topic_id], name: :index_thredded_user_topic_reads_on_topic_id
    add_index :thredded_user_topic_reads, [:user_id, :topic_id], name: :index_thredded_user_topic_reads_on_user_id_and_topic_id, unique: true
    add_column :thredded_private_posts, :filter, :string, default: 'markdown', null: false
    add_column :thredded_posts, :filter, :string, default: 'markdown', null: false
    add_column :thredded_messageboards, :filter, :string, default: 'markdown', null: false
    add_column :thredded_user_preferences, :time_zone, :string, limit: 191, default: 'Eastern Time (US & Canada)'
    change_column_null :thredded_user_messageboard_preferences, :notify_on_mention, true
    remove_index :thredded_user_messageboard_preferences, name: :thredded_user_messageboard_preferences_user_id_messageboard_id
    rename_table :thredded_user_messageboard_preferences, :thredded_notification_preferences
    add_index :thredded_notification_preferences, [:messageboard_id], name: :index_thredded_notification_preferences_on_messageboard_id
    add_index :thredded_notification_preferences, [:user_id], name: :index_thredded_notification_preferences_on_user_id
    add_column :thredded_notification_preferences, :notify_on_message, :boolean, default: true
    remove_column :thredded_user_preferences, :notify_on_mention
    remove_column :thredded_user_preferences, :notify_on_message
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/MethodLength
