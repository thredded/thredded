# frozen_string_literal: true

require 'thredded/base_migration'

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
class CreateThredded < Thredded::BaseMigration
  def change
    unless table_exists?(:friendly_id_slugs)
      # The user might have installed FriendlyId separately already.
      create_table :friendly_id_slugs do |t|
        t.string :slug, null: false
        t.integer :sluggable_id, null: false
        t.string :sluggable_type, limit: 50
        t.string :scope
        t.datetime :created_at
      end
      add_index :friendly_id_slugs, :sluggable_id
      add_index :friendly_id_slugs, %i[slug sluggable_type], length: { slug: 140, sluggable_type: 50 }
      add_index :friendly_id_slugs, %i[slug sluggable_type scope],
                length: { slug: 70, sluggable_type: 50, scope: 70 },
                unique: true
      add_index :friendly_id_slugs, :sluggable_type
    end

    create_table :thredded_categories do |t|
      t.references :messageboard, null: false, index: false
      t.text :name, null: false
      t.text :description
      t.timestamps null: false
      t.text :slug, null: false
      t.index %i[messageboard_id slug],
              name: :index_thredded_categories_on_messageboard_id_and_slug,
              unique: true,
              length: { slug: max_key_length }
      t.index [:messageboard_id], name: :index_thredded_categories_on_messageboard_id
    end
    DbTextSearch::CaseInsensitive.add_index connection, :thredded_categories, :name,
                                            name: :thredded_categories_name_ci,
                                            **(max_key_length ? { length: max_key_length } : {})

    create_table :thredded_messageboards do |t|
      t.text :name, null: false
      t.text :slug
      t.text :description
      t.integer :topics_count, default: 0
      t.integer :posts_count, default: 0
      t.integer :position, null: false
      t.references :last_topic, index: false
      t.references :messageboard_group, index: false
      t.timestamps null: false
      t.boolean :locked, null: false, default: false
      t.index [:messageboard_group_id], name: :index_thredded_messageboards_on_messageboard_group_id
      t.index [:slug],
              name: :index_thredded_messageboards_on_slug,
              unique: true,
              length: { slug: max_key_length }
    end

    create_table :thredded_posts do |t|
      t.references :user, type: user_id_type, index: false
      t.text :content, limit: 65_535
      t.string :source, limit: 191, default: 'web'
      t.references :postable, null: false, index: false
      t.references :messageboard, null: false, index: false
      t.integer :moderation_state, null: false
      t.timestamps null: false
      t.index %i[moderation_state updated_at],
              order: { updated_at: :asc },
              name:  :index_thredded_posts_for_display
      t.index [:messageboard_id], name: :index_thredded_posts_on_messageboard_id
      t.index [:postable_id], name: :index_thredded_posts_on_postable_id
      t.index %i[postable_id created_at], name: :index_thredded_posts_on_postable_id_and_created_at
      t.index [:user_id], name: :index_thredded_posts_on_user_id
    end
    DbTextSearch::FullText.add_index connection, :thredded_posts, :content, name: :thredded_posts_content_fts

    create_table :thredded_private_posts do |t|
      t.references :user, type: user_id_type, index: false
      t.text :content, limit: 65_535
      t.references :postable, null: false, index: false
      t.timestamps null: false
      t.index %i[postable_id created_at], name: :index_thredded_private_posts_on_postable_id_and_created_at
    end

    create_table :thredded_private_topics do |t|
      t.references :user, type: user_id_type, index: false
      t.references :last_user, index: false
      t.text :title, null: false
      t.text :slug, null: false
      t.integer :posts_count, default: 0
      t.string :hash_id, limit: 20, null: false
      t.datetime :last_post_at
      t.timestamps null: false
      t.index [:last_post_at], name: :index_thredded_private_topics_on_last_post_at
      t.index [:hash_id], name: :index_thredded_private_topics_on_hash_id
      t.index [:slug],
              name: :index_thredded_private_topics_on_slug,
              unique: true,
              length: { slug: max_key_length }
    end

    create_table :thredded_private_users do |t|
      t.references :private_topic, index: false
      t.references :user, type: user_id_type, index: false
      t.timestamps null: false
      t.index [:private_topic_id], name: :index_thredded_private_users_on_private_topic_id
      t.index [:user_id], name: :index_thredded_private_users_on_user_id
    end

    create_table :thredded_topic_categories do |t|
      t.references :topic, null: false, index: false
      t.references :category, null: false, index: false
      t.index [:category_id], name: :index_thredded_topic_categories_on_category_id
      t.index [:topic_id], name: :index_thredded_topic_categories_on_topic_id
    end

    create_table :thredded_topics do |t|
      t.references :user, type: user_id_type, index: false
      t.references :last_user, index: false
      t.text :title, null: false
      t.text :slug, null: false
      t.references :messageboard, null: false, index: false
      t.integer :posts_count, default: 0, null: false
      t.boolean :sticky, default: false, null: false
      t.boolean :locked, default: false, null: false
      t.string :hash_id, limit: 20, null: false
      t.integer :moderation_state, null: false
      t.datetime :last_post_at
      t.timestamps null: false
      t.index %i[moderation_state sticky updated_at],
              order: { sticky: :desc, updated_at: :desc },
              name:  :index_thredded_topics_for_display
      t.index [:last_post_at], name: :index_thredded_topics_on_last_post_at
      t.index [:hash_id], name: :index_thredded_topics_on_hash_id
      t.index [:slug],
              name: :index_thredded_topics_on_slug,
              unique: true,
              length: { slug: max_key_length }
      t.index [:messageboard_id], name: :index_thredded_topics_on_messageboard_id
      t.index [:user_id], name: :index_thredded_topics_on_user_id
    end
    DbTextSearch::FullText.add_index connection, :thredded_topics, :title, name: :thredded_topics_title_fts

    create_table :thredded_user_details do |t|
      t.references :user, type: user_id_type, null: false, index: false
      t.datetime :latest_activity_at
      t.integer :posts_count, default: 0
      t.integer :topics_count, default: 0
      t.datetime :last_seen_at
      t.integer :moderation_state, null: false, default: 0 # pending_moderation
      t.timestamp :moderation_state_changed_at
      t.timestamps null: false
      t.index %i[moderation_state moderation_state_changed_at],
              order: { moderation_state_changed_at: :desc },
              name: :index_thredded_user_details_for_moderations
      t.index %i[latest_activity_at], name: :index_thredded_user_details_on_latest_activity_at
      t.index %i[user_id], name: :index_thredded_user_details_on_user_id, unique: true
    end

    create_table :thredded_messageboard_users do |t|
      t.references :thredded_user_detail, null: false, index: false
      t.references :thredded_messageboard, null: false, index: false
      t.datetime :last_seen_at, null: false
      t.index %i[thredded_messageboard_id thredded_user_detail_id],
              name: :index_thredded_messageboard_users_primary,
              unique: true
      t.index %i[thredded_messageboard_id last_seen_at],
              name: :index_thredded_messageboard_users_for_recently_active
    end
    add_foreign_key :thredded_messageboard_users, :thredded_user_details,
                    column: :thredded_user_detail_id, on_delete: :cascade
    add_foreign_key :thredded_messageboard_users, :thredded_messageboards,
                    column: :thredded_messageboard_id, on_delete: :cascade

    create_table :thredded_user_preferences do |t|
      t.references :user, type: user_id_type, null: false, index: false
      t.boolean :follow_topics_on_mention, default: true, null: false
      t.boolean :auto_follow_topics, default: false, null: false
      t.timestamps null: false
      t.index [:user_id], name: :index_thredded_user_preferences_on_user_id, unique: true
    end

    create_table :thredded_user_messageboard_preferences do |t|
      t.references :user, type: user_id_type, null: false, index: false
      t.references :messageboard, null: false, index: false
      t.boolean :follow_topics_on_mention, default: true, null: false
      t.boolean :auto_follow_topics, default: false, null: false
      t.timestamps null: false
      t.index %i[user_id messageboard_id],
              name: :thredded_user_messageboard_preferences_user_id_messageboard_id,
              unique: true
    end

    %i[topic private_topic].each do |topics_table|
      table_name = :"thredded_user_#{topics_table}_read_states"
      create_table table_name do |t|
        t.references :messageboard, null: false, index: true if table_name == :thredded_user_topic_read_states
        t.references :user, type: user_id_type, null: false, index: false
        t.references :postable, null: false, index: false
        t.integer :unread_posts_count, default: 0, null: false
        t.integer :read_posts_count, :integer, default: 0, null: false
        t.timestamp :read_at, null: false
        t.index %i[user_id postable_id], name: :"#{table_name}_user_postable", unique: true
      end
    end
    add_index :thredded_user_topic_read_states, %i[user_id messageboard_id],
              name: :thredded_user_topic_read_states_user_messageboard

    create_table :thredded_messageboard_groups do |t|
      t.string :name
      t.integer :position, null: false
      t.timestamps null: false
    end

    create_table :thredded_user_topic_follows do |t|
      t.references :user, type: user_id_type, null: false, index: false
      t.references :topic, null: false, index: false
      t.datetime :created_at, null: false
      t.integer :reason, limit: 1
      t.index %i[user_id topic_id], name: :thredded_user_topic_follows_user_topic, unique: true
    end

    create_table :thredded_post_moderation_records do |t|
      t.references :post, index: false
      t.references :messageboard, index: false
      t.text :post_content, limit: 65_535
      t.references :post_user, index: false
      t.text :post_user_name
      t.references :moderator, index: false
      t.integer :moderation_state, null: false
      t.integer :previous_moderation_state, null: false
      t.timestamp :created_at, null: false
      t.index %i[messageboard_id created_at],
              order: { created_at: :desc },
              name:  :index_thredded_moderation_records_for_display
    end

    create_table :thredded_notifications_for_private_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id notifier_key],
              name: 'thredded_notifications_for_private_topics_unique', unique: true
    end
    create_table :thredded_notifications_for_followed_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id notifier_key],
              name: 'thredded_notifications_for_followed_topics_unique', unique: true
    end
    create_table :thredded_messageboard_notifications_for_followed_topics do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.references :messageboard, null: false, index: false
      t.string :notifier_key, null: false, limit: 90
      t.boolean :enabled, default: true, null: false
      t.index %i[user_id messageboard_id notifier_key],
              name: 'thredded_messageboard_notifications_for_followed_topics_unique', unique: true
    end

    create_table :thredded_user_post_notifications do |t|
      t.references :user, null: false, index: false, type: user_id_type
      t.references :post, null: false, index: false
      t.datetime :notified_at, null: false
      t.index :post_id, name: :index_thredded_user_post_notifications_on_post_id
      t.index %i[user_id post_id], name: :index_thredded_user_post_notifications_on_user_id_and_post_id, unique: true
    end
    add_foreign_key :thredded_user_post_notifications,
                    Thredded.user_class.table_name, column: :user_id, on_delete: :cascade
    add_foreign_key :thredded_user_post_notifications,
                    :thredded_posts, column: :post_id, on_delete: :cascade
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
