# frozen_string_literal: true

class AddViewCountToThreddedTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :view_count, :integer, default: 0
  end
end
