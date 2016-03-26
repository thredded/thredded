class RemoveRoles < ActiveRecord::Migration
  def change
    drop_table :thredded_roles
    add_column :thredded_user_details, :last_seen_at, :datetime
    remove_column :thredded_user_details, :superadmin
    create_table :thredded_messageboard_users do |t|
      t.references :thredded_user_detail, foreign_key: true, null: false
      t.references :thredded_messageboard, foreign_key: true, null: false
      t.datetime :last_seen_at, null: false
    end
    add_index :thredded_messageboard_users, [:thredded_messageboard_id, :thredded_user_detail_id],
              name: 'index_thredded_messageboard_users_primary'
    add_index :thredded_messageboard_users, [:thredded_messageboard_id, :last_seen_at],
              name: 'index_thredded_messageboard_users_for_recently_active'
    remove_column :thredded_private_topics, :messageboard_id
    remove_column :thredded_messageboards, :security
    remove_column :thredded_messageboards, :posting_permission
  end
end
