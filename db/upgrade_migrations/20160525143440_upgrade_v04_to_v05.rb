# frozen_string_literal: true
# rubocop:disable Metrics/LineLength
class UpgradeV04ToV05 < ActiveRecord::Migration
  def change
    create_table :thredded_user_topic_follows do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.datetime :created_at, null: false
      t.integer :reason, limit: 1
    end
    add_index :thredded_user_topic_follows, [:user_id, :topic_id], name: :thredded_user_topic_follows_user_topic, unique: true
  end
end
# rubocop:enable Metrics/LineLength
