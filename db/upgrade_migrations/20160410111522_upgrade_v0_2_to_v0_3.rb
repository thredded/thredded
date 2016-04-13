class UpgradeV02ToV03 < ActiveRecord::Migration
  def up
    remove_index :thredded_notification_preferences, name: :index_thredded_notification_preferences_on_messageboard_id
    remove_index :thredded_notification_preferences, name: :index_thredded_notification_preferences_on_user_id
    rename_table :thredded_notification_preferences, :thredded_user_messageboard_preferences
    remove_column :thredded_user_messageboard_preferences, :notify_on_message
    change_column_null :thredded_user_messageboard_preferences, :notify_on_mention, false
    add_column :thredded_user_preferences, :notify_on_mention, :boolean, default: true, null: false
    add_column :thredded_user_preferences, :notify_on_message, :boolean, default: true, null: false
    add_index :thredded_user_messageboard_preferences, [:user_id, :messageboard_id], unique: true, name: :thredded_user_messageboard_preferences_user_id_messageboard_id
    remove_column :thredded_user_preferences, :time_zone
    remove_column :thredded_messageboards, :filter
    remove_column :thredded_posts, :filter
    remove_column :thredded_private_posts, :filter
  end

  def down
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
