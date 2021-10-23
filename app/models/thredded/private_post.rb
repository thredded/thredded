# frozen_string_literal: true

module Thredded
  class PrivatePost < ActiveRecord::Base
    include Thredded::PostCommon

    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_private_posts,
               optional: true
    belongs_to :postable,
               class_name:    'Thredded::PrivateTopic',
               inverse_of:    :posts,
               counter_cache: :posts_count
    belongs_to :user_detail,
               inverse_of:  :private_posts,
               primary_key: :user_id,
               foreign_key: :user_id,
               optional: true

    after_commit :update_parent_last_user_and_timestamp, on: %i[create destroy]
    after_commit :notify_users, on: [:create]

    # Finds the post by its ID, or raises {Thredded::Errors::PrivatePostNotFound}.
    # @param id [String, Number]
    # @return [Thredded::PrivatePost]
    # @raise [Thredded::Errors::PrivatePostNotFound] if the post with the given ID does not exist.
    def self.find!(id)
      find_by(id: id) || fail(Thredded::Errors::PrivatePostNotFound)
    end

    # @param [Integer] per_page
    def page(per_page: self.class.default_per_page)
      calculate_page(postable.posts, per_page)
    end

    def private_topic_post?
      true
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users that can read this post.
    def readers
      collection_proxy = postable.users
      if persisted?
        collection_proxy.scope
      else
        Thredded.user_class.where(id: collection_proxy.to_a.map(&:id))
      end
    end

    private

    def notify_users
      Thredded::NotifyPrivateTopicUsersJob.perform_later(id)
    end

    def update_parent_last_user_and_timestamp
      return if postable.destroyed?
      last_post = if destroyed?
                    postable.posts.order_oldest_first.select(:user_id, :created_at).last
                  else
                    self
                  end
      postable.update_columns(
        last_user_id: last_post.user_id,
        last_post_at: last_post.created_at,
        updated_at: Time.zone.now
      )
    end
  end
end
