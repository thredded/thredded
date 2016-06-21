# frozen_string_literal: true
module Thredded
  module ModeratePost
    module_function

    # @param [Post] post
    # @param [Symbol] moderation_state
    # @param [Thredded.user_class] moderator
    # @return [Thredded::PostModerationRecord]
    def run!(post:, moderation_state:, moderator:)
      Thredded::Post.transaction do
        post_moderation_record = Thredded::PostModerationRecord.record!(
          moderator: moderator,
          post: post,
          previous_moderation_state: post.moderation_state,
          moderation_state: moderation_state,
        )
        if post.user_id && post.user_detail.pending_moderation?
          update_without_timestamping!(post.user_detail, moderation_state: moderation_state)
        end
        if post.postable.first_post == post
          update_without_timestamping!(post.postable, moderation_state: moderation_state)
          if moderation_state == :blocked
            # When blocking the first post of a topic, also block all the other posts in the topic by this user.
            post.postable.posts.where(user_id: post.user.id).where.not(id: post.id).each do |a_post|
              update_without_timestamping!(a_post, moderation_state: moderation_state)
            end
          end
        end
        update_without_timestamping!(post, moderation_state: moderation_state)
        post_moderation_record
      end
    end

    # @param record [ActiveRecord]
    # @api private
    def update_without_timestamping!(record, *attr)
      record_timestamps_was = record.record_timestamps
      begin
        record.record_timestamps = false
        record.update!(*attr)
      ensure
        record.record_timestamps = record_timestamps_was
      end
    end
  end
end
