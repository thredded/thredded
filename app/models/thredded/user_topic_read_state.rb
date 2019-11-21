# frozen_string_literal: true

module Thredded
  class UserTopicReadState < ActiveRecord::Base
    include Thredded::UserTopicReadStateCommon
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_topic_read_states
    belongs_to :postable,
               class_name: 'Thredded::Topic',
               inverse_of: :user_read_states
    belongs_to :messageboard,
               class_name: 'Thredded::Messageboard',
               inverse_of: :user_topic_read_states

    class << self
      def topic_class
        Thredded::Topic
      end

      def visible_posts_scope(user)
        Thredded::Post.moderation_state_visible_to_user(user)
      end

      # @param [Integer] user_id
      # @param [Thredded::Post] post
      # @param [Boolean] overwrite_newer
      def touch!(user_id, post, overwrite_newer: false)
        state = find_or_initialize_by(user_id: user_id, postable_id: post.postable_id)
        return if !overwrite_newer && state.read_at? && state.read_at >= post.created_at
        state.messageboard_id = post.messageboard_id
        state.read_at = post.created_at
        state.update!(state.calculate_post_counts)
      rescue ActiveRecord::RecordNotUnique
        # The record has been created from another connection, retry to find it.
        retry
      end

      # @param [Thredded.user_class] user
      # @param [Thredded::Post] post
      def read_on_first_post!(user, post)
        create!(user: user, postable_id: post.postable_id, messageboard_id: post.messageboard_id,
                read_at: post.created_at, read_posts_count: 1, unread_posts_count: 0)
      end

      protected

      # @param [Array<Thredded.user_class>] users
      # @return [Array<[id, unread_count, read_count]>]
      def calculate_post_counts_for_users(users)
        users
          .group_by { |user| visible_posts_scope(user) }
          .flat_map { |s, u| where(user_id: u.map(&:id)).merge(s).calculate_post_counts }
      end
    end
  end
end
