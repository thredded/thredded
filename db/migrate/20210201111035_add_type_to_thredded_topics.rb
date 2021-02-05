# frozen_string_literal: true

class AddTypeToThreddedTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :type, :string, default: 'Thredded::TopicDefault'
  end
end
