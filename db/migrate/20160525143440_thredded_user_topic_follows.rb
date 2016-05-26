# frozen_string_literal: true
class ThreddedUserTopicFollows < ActiveRecord::Migration
  def change
    create_table :thredded_user_topic_follows do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.datetime :created_at, null: false
      t.string :reason, default: 'manual'
    end
  end
end
