# This migration comes from thredded (originally 20130425230852)
class CreateThreddedTables < ActiveRecord::Migration
  def change
    create_table :thredded_attachments do |t|
      t.string  :attachment
      t.string  :content_type
      t.integer :file_size
      t.integer :post_id
      t.timestamps
    end

    create_table :thredded_categories do |t|
      t.integer  :messageboard_id, null: false
      t.string   :name, null: false
      t.string   :description
      t.timestamps
    end

    create_table :thredded_images do |t|
      t.integer :post_id
      t.integer :width
      t.integer :height
      t.string  :orientation
      t.timestamps
    end

    create_table :thredded_messageboards do |t|
      t.string   :name, null: false
      t.string   :slug
      t.text     :description
      t.string   :security, default: 'public'
      t.string   :posting_permission, default: 'anonymous'
      t.integer  :topics_count, default: 0
      t.integer  :posts_count, default: 0
      t.boolean  :closed, default: false, null: false
      t.timestamps
    end

    add_index :thredded_messageboards, :closed

    create_table :thredded_post_notifications do |t|
      t.string   :email, null: false
      t.integer  :post_id, null: false
      t.timestamps
    end

    create_table :thredded_posts do |t|
      t.integer  :user_id
      t.string   :user_email
      t.text     :content
      t.string   :ip
      t.string   :filter, default: 'markdown'
      t.string   :source, default: 'web'
      t.integer  :topic_id, null: false
      t.integer  :messageboard_id, null: false
      t.timestamps
    end

    create_table :thredded_private_users do |t|
      t.integer  :private_topic_id
      t.integer  :user_id
      t.timestamps
    end

    create_table :thredded_messageboard_preferences do |t|
      t.boolean  :notify_on_mention, default: true
      t.boolean  :notify_on_message, default: true
      t.string   :filter, default: 'markdown', null: false
      t.integer  :user_id, null: false
      t.integer  :messageboard_id, null: false
      t.timestamps
    end

    add_index :thredded_messageboard_preferences, :user_id
    add_index :thredded_messageboard_preferences, :messageboard_id

    create_table :thredded_roles do |t|
      t.string   :level
      t.integer  :user_id
      t.integer  :messageboard_id
      t.datetime :last_seen
      t.timestamps
    end

    add_index :thredded_roles, :user_id
    add_index :thredded_roles, :messageboard_id

    create_table :thredded_topic_categories do |t|
      t.integer :topic_id, null: false
      t.integer :category_id, null: false
    end

    create_table :thredded_topics do |t|
      t.integer  :user_id, null: false
      t.integer  :last_user_id, null: false
      t.string   :title, null: false
      t.string   :slug, null: false
      t.integer  :messageboard_id, null: false
      t.integer  :posts_count, default: 0
      t.string   :attribs, default: '[]'
      t.boolean  :sticky, default: false
      t.boolean  :locked, default: false
      t.string   :hash_id, null: false
      t.string   :state, default: 'approved', null: false
      t.string   :type
      t.timestamps
    end

    create_table :thredded_user_details do |t|
      t.integer :user_id, null: false
      t.datetime :latest_activity_at
      t.integer :posts_count, default: 0
      t.integer :topics_count, default: 0
      t.boolean :superadmin, default: false
      t.timestamps
    end

    add_index :thredded_user_details, :user_id
    add_index :thredded_user_details, :latest_activity_at

    create_table :thredded_user_preferences do |t|
      t.integer :user_id, null: false
      t.string :time_zone, default: 'Eastern Time (US & Canada)'
      t.timestamps
    end

    add_index :thredded_user_preferences, :user_id

    create_table :thredded_user_topic_reads do |t|
      t.integer  :user_id, null: false
      t.integer  :topic_id, null: false
      t.integer  :post_id, null: false
      t.integer  :posts_count, default: 0, null: false
      t.integer  :page, default: 1, null: false
      t.timestamps
    end

    add_index :thredded_user_topic_reads, :user_id
    add_index :thredded_user_topic_reads, :topic_id
    add_index :thredded_user_topic_reads, :post_id
    add_index :thredded_user_topic_reads, :page
    add_index :thredded_user_topic_reads, :posts_count
  end
end
