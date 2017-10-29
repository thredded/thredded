class AddLockToThreddedMessageboard < ActiveRecord::Migration[5.1]
  def change
    add_column :thredded_messageboards, :locked, :boolean, :null => false, :default => false
  end
end
