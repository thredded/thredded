# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeThreddedV010ToV011 < Thredded::BaseMigration
  def up
    drop_table :thredded_post_notifications
    add_column :thredded_user_preferences, :auto_follow_topics, :boolean, default: false, null: false
    add_column :thredded_user_messageboard_preferences, :auto_follow_topics, :boolean, default: false, null: false
  end

  def down
    remove_column :thredded_user_messageboard_preferences, :auto_follow_topics
    remove_column :thredded_user_preferences, :auto_follow_topics
    create_table :thredded_post_notifications do |t|
      t.string :email, limit: 191, null: false
      t.references :post, null: false, index: false
      t.timestamps null: false
      t.string :post_type, limit: 191
      t.index %i[post_id post_type], name: :index_thredded_post_notifications_on_post
    end
  end
end
