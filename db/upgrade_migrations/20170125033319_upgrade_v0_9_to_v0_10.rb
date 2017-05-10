# frozen_string_literal: true

class UpgradeV09ToV010 < (Thredded.rails_gte_51? ? ActiveRecord::Migration[5.1] : ActiveRecord::Migration)
  def up
    remove_foreign_key :thredded_messageboard_users, :thredded_messageboards
    add_foreign_key :thredded_messageboard_users, :thredded_messageboards, on_delete: :cascade
    remove_foreign_key :thredded_messageboard_users, :thredded_user_details
    add_foreign_key :thredded_messageboard_users, :thredded_user_details, on_delete: :cascade

    create_table :thredded_user_post_notifications do |t|
      t.references :user, null: false, index: false
      t.foreign_key Thredded.user_class.table_name, column: :user_id, on_delete: :cascade
      t.references :post, null: false, index: false
      t.foreign_key :thredded_posts, column: :post_id, on_delete: :cascade
      t.datetime :notified_at, null: false
      t.index :post_id, name: :index_thredded_user_post_notifications_on_post_id
      t.index %i[user_id post_id], name: :index_thredded_user_post_notifications_on_user_id_and_post_id, unique: true
    end
  end

  def down
    drop_table :thredded_user_post_notifications

    remove_foreign_key :thredded_messageboard_users, :thredded_user_details
    add_foreign_key :thredded_messageboard_users, :thredded_user_details
    remove_foreign_key :thredded_messageboard_users, :thredded_messageboards
    add_foreign_key :thredded_messageboard_users, :thredded_messageboards
  end
end
