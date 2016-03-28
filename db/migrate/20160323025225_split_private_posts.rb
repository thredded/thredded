class SplitPrivatePosts < ActiveRecord::Migration
  def change
    create_table :thredded_private_posts do |t|
      t.integer :user_id
      t.text :content
      t.string :ip
      t.string :filter, default: 'markdown'
      t.integer :postable_id, null: false
      t.timestamps
    end
    add_column :thredded_post_notifications, :post_type, :string
    add_index :thredded_post_notifications, [:post_id, :post_type], name: :index_thredded_post_notifications_on_post
    migrate_data
    remove_index :thredded_post_notifications, name: :index_thredded_post_notifications_on_post_id
    remove_column :thredded_posts, :postable_type
  end

  private
  def migrate_data
    # Disable all timestamp handling
    ActiveRecord::Base.record_timestamps = false
    # Rails 4.1 has .no_touching, but 4.0 does not
    original_touch = ActiveRecord::Base.instance_method(:touch)
    ActiveRecord::Base.send(:define_method, :touch) { |*| }

    Thredded::PostNotification.reset_column_information
    old_private_posts = Thredded::Post.where(postable_type: 'Thredded::PrivateTopic')
    old_private_posts.
      pluck(:id, :user_id, :content, :ip, :filter, :postable_id, :created_at, :updated_at).
      each do |(id, user_id, content, ip, filter, postable_id, created_at, updated_at)|
      private_post              = Thredded::PrivatePost.create!(
        user_id:     user_id,
        content:     content.blank? ? '...' : content,
        ip:          ip,
        filter:      filter,
        postable_id: postable_id,
        created_at:  created_at,
        updated_at:  updated_at,
      )
      old_private_notifications = Thredded::PostNotification.where(post_id: id)
      old_private_notifications.each do |old_private_notification|
        Thredded::PostNotification.create!(email: old_private_notification.email, post: private_post)
      end
      old_private_notifications.delete_all
    end
    old_private_posts.delete_all
  ensure
    # Re-enable timestamp handling
    ActiveRecord::Base.record_timestamps = true
    ActiveRecord::Base.send(:define_method, :touch, original_touch)
  end
end
