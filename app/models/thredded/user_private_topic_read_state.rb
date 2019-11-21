# frozen_string_literal: true

module Thredded
  class UserPrivateTopicReadState < ActiveRecord::Base
    include Thredded::UserTopicReadStateCommon
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_private_topic_read_states
    belongs_to :postable,
               class_name: 'Thredded::PrivateTopic',
               inverse_of: :user_read_states

    class << self
      def topic_class
        Thredded::PrivateTopic
      end

      def visible_posts_scope(_user)
        Thredded::PrivatePost.all
      end

      # @param [Integer] user_id
      # @param [Thredded::PrivatePost] post
      # @param [Boolean] overwrite_newer
      def touch!(user_id, post, overwrite_newer: false)
        state = find_or_initialize_by(user_id: user_id, postable_id: post.postable_id)
        return if !overwrite_newer && state.read_at? && state.read_at >= post.created_at
        state.read_at = post.created_at
        state.update!(state.calculate_post_counts)
      rescue ActiveRecord::RecordNotUnique
        # The record has been created from another connection, retry to find it.
        retry
      end

      # @param [Thredded.user_class] user
      # @param [Thredded::PrivatePost] post
      def read_on_first_post!(user, post)
        create!(user: user, postable_id: post.postable_id, read_at: post.created_at, read_posts_count: 1,
                unread_posts_count: 0)
      end

      protected

      # @param [Array<Thredded.user_class>] users
      # @return [Array<[id, unread_count, read_count]>]
      def calculate_post_counts_for_users(users)
        where(user_id: users.map(&:id)).calculate_post_counts
      end
    end
  end
end
