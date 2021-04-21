class AddHashToRelaunchUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_relaunch_users, :user_hash, :string
  end
end
