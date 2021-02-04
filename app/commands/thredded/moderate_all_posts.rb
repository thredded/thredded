# frozen_string_literal: true

module Thredded
  module ModerateAllPosts
    module_function

    # @param [Thredded::Post[]] posts_scope
    # @param [Symbol] moderation_state
    # @param [Thredded.user_class] moderator
    # @return [Thredded::PostModerationRecord]
    def run!(posts_scope:, moderation_state:, moderator:)
      return if moderation_state == :pending_moderation
      posts_scope.each do |post|
        Thredded::ModeratePost.run!(
          post: post,
          moderation_state: moderation_state,
          moderator: moderator,
        )
      end
    end
  end
end
