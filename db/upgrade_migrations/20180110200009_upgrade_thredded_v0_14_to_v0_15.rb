# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeThreddedV014ToV015 < Thredded::BaseMigration
  def change # rubocop:disable Metrics/MethodLength
    # Work around race condition on last_seen_at update
    # https://github.com/thredded/thredded/pull/674
    remove_index :thredded_messageboard_users,
                 name: :index_thredded_messageboard_users_primary
    add_index :thredded_messageboard_users,
              %i[thredded_messageboard_id thredded_user_detail_id],
              name: :index_thredded_messageboard_users_primary,
              unique: true

    # Remove database string length limits.
    # https://github.com/thredded/thredded/pull/703
    remove_index :thredded_categories, name: :thredded_categories_name_ci
    remove_string_limit :thredded_categories, :name
    DbTextSearch::CaseInsensitive.add_index connection, :thredded_categories, :name,
                                            name: :thredded_categories_name_ci,
                                            **(max_key_length ? { length: max_key_length } : {})
    remove_string_limit :thredded_categories, :description
    remove_string_limit :thredded_categories, :slug,
                        indices: [
                          [%i[messageboard_id slug],
                           name: :index_thredded_categories_on_messageboard_id_and_slug,
                           unique: true,
                           length: { slug: max_key_length }]
                        ]

    remove_string_limit :thredded_messageboards, :name
    remove_string_limit :thredded_messageboards, :slug,
                        indices: [
                          [%i[slug],
                           name: :index_thredded_messageboards_on_slug,
                           unique: true,
                           length: { slug: max_key_length }]
                        ]

    change_column :thredded_posts, :ip, :string, limit: 45
    change_column :thredded_posts, :source, :string, limit: 191

    remove_string_limit :thredded_private_topics, :title
    remove_string_limit :thredded_private_topics, :slug,
                        indices: [
                          [%i[slug],
                           name: :index_thredded_private_topics_on_slug,
                           unique: true,
                           length: { slug: max_key_length }]
                        ]
    change_column :thredded_private_topics, :hash_id, :string, limit: 20

    remove_string_limit :thredded_topics, :title
    remove_string_limit :thredded_topics, :slug,
                        indices: [
                          [%i[slug],
                           name: :index_thredded_topics_on_slug,
                           unique: true,
                           length: { slug: max_key_length }]
                        ]
    change_column :thredded_topics, :hash_id, :string, limit: 20
    remove_column :thredded_topics, :type

    # Remove IP tracking column from posts
    # https://github.com/thredded/thredded/pull/705
    remove_column :thredded_posts, :ip
    remove_column :thredded_private_posts, :ip

    # Jump to first unread post
    # https://github.com/thredded/thredded/pull/695
    remove_column :thredded_user_topic_read_states, :page
    remove_column :thredded_user_private_topic_read_states, :page
    add_index :thredded_topics, [:last_post_at], name: :index_thredded_topics_on_last_post_at
    add_index :thredded_private_topics, [:last_post_at], name: :index_thredded_private_topics_on_last_post_at
    add_index :thredded_posts, %i[postable_id created_at], name: :index_thredded_posts_on_postable_id_and_created_at
    add_index :thredded_private_posts, %i[postable_id created_at],
              name: :index_thredded_private_posts_on_postable_id_and_created_at

    # Cleanup
    remove_index :thredded_posts, name: :index_thredded_posts_on_postable_id_and_created_at
  end

  private

  def remove_string_limit(table, column, type: :text, indices: [])
    indices.each { |(_, options)| remove_index table, name: options[:name] }
    change_column table, column, type, limit: nil
    indices.each { |args| add_index table, *args }
  end
end
