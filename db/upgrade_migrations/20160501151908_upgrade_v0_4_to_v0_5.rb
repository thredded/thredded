# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
class UpgradeV04ToV05 < ActiveRecord::Migration
  def change
    # Topic following
    create_table :thredded_user_topic_follows do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.datetime :created_at, null: false
      t.integer :reason, limit: 1
      t.index [:user_id, :topic_id], name: :thredded_user_topic_follows_user_topic, unique: true
    end

    # Moderation
    change_table :thredded_posts, bulk: true do |t|
      t.integer :moderation_state, null: false, default: 1
      t.index [:moderation_state, :updated_at],
              order: { updated_at: :asc },
              name:  :index_thredded_posts_for_display
    end
    change_column_default :thredded_posts, :moderation_state, from: 1, to: nil

    change_table :thredded_topics, bulk: true do |t|
      t.integer :moderation_state, null: false, default: 1
      t.index %i(moderation_state sticky updated_at),
              order: { sticky: :desc, updated_at: :desc },
              name:  :index_thredded_topics_for_display
    end
    change_column_default :thredded_topics, :moderation_state, from: 1, to: nil

    change_table :thredded_user_details do |t|
      t.integer :moderation_state, null: false, default: 1
      t.timestamp :moderation_state_changed_at
      t.index %i(moderation_state moderation_state_changed_at),
              order: { moderation_state_changed_at: :desc },
              name: :index_thredded_user_details_for_moderations
    end
    change_column_default :thredded_user_details, :moderation_state, from: 1, to: 0 # pending_moderation

    create_table :thredded_post_moderation_records do |t|
      t.references :post
      t.references :messageboard
      t.text :post_content, limit: 65_535
      t.references :post_user
      t.text :post_user_name
      t.references :moderator
      t.integer :moderation_state, null: false
      t.integer :previous_moderation_state, null: false
      t.timestamp :created_at, null: false
      t.index [:messageboard_id, :created_at],
              order: { created_at: :desc },
              name:  :index_thredded_moderation_records_for_display
    end
  end
end
# rubocop:enable Metrics/MethodLength
