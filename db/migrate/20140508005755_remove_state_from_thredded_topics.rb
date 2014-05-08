class RemoveStateFromThreddedTopics < ActiveRecord::Migration
  def up
    remove_column :thredded_topics, :state
  end

  def down
    add_column :thredded_topics, :state, :string, default: 'approved', null: false
  end
end
