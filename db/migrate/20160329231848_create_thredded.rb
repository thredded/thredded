# frozen_string_literal: true
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/LineLength
class CreateThredded < ActiveRecord::Migration
  def change
    unless table_exists?(:friendly_id_slugs)
      # The user might have installed FriendlyId separately already.
      create_table :friendly_id_slugs do |t|
        t.string :slug, limit: 191, null: false
        t.integer :sluggable_id, null: false
        t.string :sluggable_type, limit: 50
        t.string :scope, limit: 191
        t.datetime :created_at, null: false
      end
      add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], name: :index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope, unique: true
      add_index :friendly_id_slugs, [:slug, :sluggable_type], name: :index_friendly_id_slugs_on_slug_and_sluggable_type
      add_index :friendly_id_slugs, [:sluggable_id], name: :index_friendly_id_slugs_on_sluggable_id
      add_index :friendly_id_slugs, [:sluggable_type], name: :index_friendly_id_slugs_on_sluggable_type
    end

    create_table :thredded_categories do |t|
      t.integer :messageboard_id, null: false
      t.string :name, limit: 191, null: false
      t.string :description, limit: 255
      t.timestamps null: false
      t.string :slug, limit: 191, null: false
    end
    add_index :thredded_categories, [:messageboard_id, :slug], name: :index_thredded_categories_on_messageboard_id_and_slug, unique: true
    add_index :thredded_categories, [:messageboard_id], name: :index_thredded_categories_on_messageboard_id
    DbTextSearch::CaseInsensitive.add_index connection, :thredded_categories, :name, name: :thredded_categories_name_ci

    create_table :thredded_messageboards do |t|
      t.string :name, limit: 255, null: false
      t.string :slug, limit: 191
      t.text :description
      t.integer :topics_count, default: 0
      t.integer :posts_count, default: 0
      t.boolean :closed, default: false, null: false
      t.references :messageboard_group
      t.timestamps null: false
      t.index [:messageboard_group_id], name: :index_thredded_messageboards_on_messageboard_group_id
    end
    add_index :thredded_messageboards, [:closed], name: :index_thredded_messageboards_on_closed
    add_index :thredded_messageboards, [:slug], name: :index_thredded_messageboards_on_slug

    create_table :thredded_post_notifications do |t|
      t.string :email, limit: 191, null: false
      t.integer :post_id, null: false
      t.timestamps null: false
      t.string :post_type, limit: 191
    end
    add_index :thredded_post_notifications, [:post_id, :post_type], name: :index_thredded_post_notifications_on_post

    create_table :thredded_posts do |t|
      t.integer :user_id, limit: 4
      t.text :content, limit: 65_535
      t.string :ip, limit: 255
      t.string :source, limit: 255, default: 'web'
      t.integer :postable_id, limit: 4
      t.integer :messageboard_id, null: false
      t.integer :moderation_state, null: false
      t.timestamps null: false
      t.index [:moderation_state, :updated_at],
              order: { updated_at: :asc },
              name:  :index_thredded_posts_for_display
    end
    add_index :thredded_posts, [:messageboard_id], name: :index_thredded_posts_on_messageboard_id
    add_index :thredded_posts, [:postable_id], name: :index_thredded_posts_on_postable_id
    add_index :thredded_posts, [:postable_id], name: :index_thredded_posts_on_postable_id_and_postable_type
    add_index :thredded_posts, [:user_id], name: :index_thredded_posts_on_user_id
    DbTextSearch::FullText.add_index connection, :thredded_posts, :content, name: :thredded_posts_content_fts

    create_table :thredded_private_posts do |t|
      t.integer :user_id, limit: 4
      t.text :content, limit: 65_535
      t.string :ip, limit: 255
      t.integer :postable_id, null: false
      t.timestamps null: false
    end

    create_table :thredded_private_topics do |t|
      t.integer :user_id, null: false
      t.integer :last_user_id, null: false
      t.string :title, limit: 255, null: false
      t.string :slug, limit: 191, null: false
      t.integer :posts_count, default: 0
      t.string :hash_id, limit: 191, null: false
      t.timestamps null: false
    end
    add_index :thredded_private_topics, [:hash_id], name: :index_thredded_private_topics_on_hash_id
    add_index :thredded_private_topics, [:slug], name: :index_thredded_private_topics_on_slug

    create_table :thredded_private_users do |t|
      t.integer :private_topic_id, limit: 4
      t.integer :user_id, limit: 4
      t.timestamps null: false
    end
    add_index :thredded_private_users, [:private_topic_id], name: :index_thredded_private_users_on_private_topic_id
    add_index :thredded_private_users, [:user_id], name: :index_thredded_private_users_on_user_id

    create_table :thredded_topic_categories do |t|
      t.integer :topic_id, null: false
      t.integer :category_id, null: false
    end
    add_index :thredded_topic_categories, [:category_id], name: :index_thredded_topic_categories_on_category_id
    add_index :thredded_topic_categories, [:topic_id], name: :index_thredded_topic_categories_on_topic_id

    create_table :thredded_topics do |t|
      t.integer :user_id, null: false
      t.integer :last_user_id, null: false
      t.string :title, limit: 255, null: false
      t.string :slug, limit: 191, null: false
      t.integer :messageboard_id, null: false
      t.integer :posts_count, default: 0, null: false
      t.boolean :sticky, default: false, null: false
      t.boolean :locked, default: false, null: false
      t.string :hash_id, limit: 191, null: false
      t.string :type, limit: 191
      t.integer :moderation_state, null: false
      t.timestamps null: false
      t.index %i(moderation_state sticky updated_at),
              order: { sticky: :desc, updated_at: :desc },
              name:  :index_thredded_topics_for_display
    end
    add_index :thredded_topics, [:hash_id], name: :index_thredded_topics_on_hash_id
    add_index :thredded_topics, [:messageboard_id, :slug], name: :index_thredded_topics_on_messageboard_id_and_slug, unique: true
    add_index :thredded_topics, [:messageboard_id], name: :index_thredded_topics_on_messageboard_id
    add_index :thredded_topics, [:user_id], name: :index_thredded_topics_on_user_id
    DbTextSearch::FullText.add_index connection, :thredded_topics, :title, name: :thredded_topics_title_fts

    create_table :thredded_user_details do |t|
      t.integer :user_id, null: false
      t.datetime :latest_activity_at
      t.integer :posts_count, default: 0
      t.integer :topics_count, default: 0
      t.datetime :last_seen_at
      t.integer :moderation_state, null: false, default: 0 # pending_moderation
      t.timestamp :moderation_state_changed_at
      t.timestamps null: false
      t.index %i(moderation_state moderation_state_changed_at),
              order: { moderation_state_changed_at: :desc },
              name: :index_thredded_user_details_for_moderations
      t.index %i(latest_activity_at), name: :index_thredded_user_details_on_latest_activity_at
      t.index %i(user_id), name: :index_thredded_user_details_on_user_id
    end

    create_table :thredded_messageboard_users do |t|
      t.references :thredded_user_detail, foreign_key: true, null: false
      t.references :thredded_messageboard, foreign_key: true, null: false
      t.datetime :last_seen_at, null: false
    end
    add_index :thredded_messageboard_users, [:thredded_messageboard_id, :thredded_user_detail_id],
              name: :index_thredded_messageboard_users_primary
    add_index :thredded_messageboard_users, [:thredded_messageboard_id, :last_seen_at],
              name: :index_thredded_messageboard_users_for_recently_active

    create_table :thredded_user_preferences do |t|
      t.integer :user_id, null: false
      t.boolean :notify_on_mention, default: true, null: false
      t.boolean :notify_on_message, default: true, null: false
      t.timestamps null: false
    end
    add_index :thredded_user_preferences, [:user_id], name: :index_thredded_user_preferences_on_user_id

    create_table :thredded_user_messageboard_preferences do |t|
      t.integer :user_id, null: false
      t.integer :messageboard_id, null: false
      t.boolean :notify_on_mention, default: true, null: false
      t.timestamps null: false
    end
    add_index :thredded_user_messageboard_preferences, [:user_id, :messageboard_id],
              unique: true,
              name: :thredded_user_messageboard_preferences_user_id_messageboard_id

    %i(topic private_topic).each do |topics_table|
      table_name = :"thredded_user_#{topics_table}_read_states"
      create_table table_name do |t|
        t.integer :user_id, null: false
        t.integer :postable_id, null: false
        t.integer :page, default: 1, null: false
        t.timestamp :read_at, null: false
      end
      add_index table_name, [:user_id, :postable_id], name: :"#{table_name}_user_postable", unique: true
    end

    create_table :thredded_messageboard_groups do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :thredded_user_topic_follows do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.datetime :created_at, null: false
      t.integer :reason, limit: 1
    end
    add_index :thredded_user_topic_follows, [:user_id, :topic_id], name: :thredded_user_topic_follows_user_topic, unique: true

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
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
