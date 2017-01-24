class FollowTopicsOnCreate < ActiveRecord::Migration
  def change
    add_column :thredded_user_preferences, :auto_follow_topics, :boolean, default: false, null: false
    add_column :thredded_user_messageboard_preferences, :auto_follow_topics, :boolean, default: false, null: false
  end
end
