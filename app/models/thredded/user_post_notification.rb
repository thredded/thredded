# frozen_string_literal: true

module Thredded
  # Delivery records for Thredded::Post notifications.
  class UserPostNotification < ActiveRecord::Base
    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_post_notifications
    belongs_to :post, class_name: 'Thredded::Post', inverse_of: :user_notifications

    # @param post [Thredded::Post]
    # @return [Array<Integer>] The IDs of users who were already notified about the given post.
    def self.notified_user_ids(post)
      where(post_id: post.id).pluck(:user_id)
    end

    # Create a user-post notification record for a given post and a user.
    # @param post [Thredded::Post]
    # @param user [Thredded.user_class]
    # @return [Boolean] true if a new record was created, false otherwise (e.g. if a record had already existed).
    def self.create_from_post_and_user(post, user)
      create(
        post_id: post.id,
        user_id: user.id,
        notified_at: Time.zone.now
      )
    rescue ActiveRecord::RecordNotUnique
      false
    end
  end
end
