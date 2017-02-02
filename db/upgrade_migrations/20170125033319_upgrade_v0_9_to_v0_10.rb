class UpgradeV09ToV010 < ActiveRecord::Migration
  def change
    remove_foreign_key :thredded_messageboard_users, :thredded_messageboards
    add_foreign_key :thredded_messageboard_users, :thredded_messageboards, on_delete: :cascade
    remove_foreign_key :thredded_messageboard_users, :thredded_user_details
    add_foreign_key :thredded_messageboard_users, :thredded_user_details, on_delete: :cascade
  end
end
