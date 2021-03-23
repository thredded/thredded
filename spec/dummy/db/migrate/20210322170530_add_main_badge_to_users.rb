class AddMainBadgeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :thredded_main_badge, foreign_key: {to_table: :thredded_badges}
  end
end
