class AddBadgeToMessageboardsAndTopics < ActiveRecord::Migration[6.0]
  def change
    add_reference :thredded_messageboards, :badge, foreign_key: {to_table: :thredded_badges}
    add_reference :thredded_topics, :badge, foreign_key: {to_table: :thredded_badges}
  end
end
