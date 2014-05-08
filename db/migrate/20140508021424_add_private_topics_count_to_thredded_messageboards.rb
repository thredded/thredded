class AddPrivateTopicsCountToThreddedMessageboards < ActiveRecord::Migration
  def change
    add_column :thredded_messageboards, :private_topics_count, :integer, default: 0
  end
end
