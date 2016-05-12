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
        if post.user_detail.pending_moderation?
          post.user_detail.update!(moderation_state: moderation_state)
        end
        if post.postable.first_post == post
          post.postable.update!(moderation_state: moderation_state)
          if moderation_state == :blocked
            # When blocking the first post of a topic, also block all the other posts in the topic by this user.
            post.postable.posts.where(user_id: post.user.id).where.not(id: post.id).each do |a_post|
              a_post.update!(moderation_state: moderation_state)
            end
          end
        end
        post.update!(moderation_state: moderation_state)
        post_moderation_record
      end
    end
  end
end
