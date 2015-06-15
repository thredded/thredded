class RenameMessageboardPreferences < ActiveRecord::Migration
  def change
    rename_table :thredded_messageboard_preferences,
      :thredded_notification_preferences
  end
end
