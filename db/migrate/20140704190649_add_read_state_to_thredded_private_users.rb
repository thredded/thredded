class AddReadStateToThreddedPrivateUsers < ActiveRecord::Migration
  def change
    add_column :thredded_private_users, :read, :boolean, default: false
    add_index :thredded_private_users, :read
  end
end
