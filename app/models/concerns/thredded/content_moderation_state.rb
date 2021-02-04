# frozen_string_literal: true

module Thredded
  # Moderation state of a piece of content, such as a Thredded::Topic or a Thredded::Post.
  # Requires an integer moderation_state column, a user_id column, and a user_detail association on the including class.
  # @api private
  module ContentModerationState
    extend ActiveSupport::Concern
    include Thredded::ModerationState

    included do
      before_validation :set_default_moderation_state, on: :create

      scope :moderation_state_visible_to_all, -> do
        if Thredded.content_visible_while_pending_moderation
          # All non-blocked content
          where.not(moderation_state: moderation_states[:blocked])
        else
          # Only approved content
          where(moderation_state: moderation_states[:approved])
        end
      end

      scope :moderation_state_visible_to_user, ->(user) {
        moderatable_messageboards = user.thredded_can_moderate_messageboards
        if moderatable_messageboards == Thredded::Messageboard.all
          # If the user can moderate all messageboards, they can see all the content.
          result = all
        else
          # Visible to all.
          result = moderation_state_visible_to_all

          # Own content.
          result = result.or(where(user_id: user.id)) if user && !user.thredded_anonymous?

          # Content that the user can moderate.
          result = result.or(where(messageboard_id: moderatable_messageboards)) if moderatable_messageboards != Thredded::Messageboard.none
        end
        result
      }
    end

    # Whether this is visible to anyone based on the moderation state.
    def moderation_state_visible_to_all?
      if Thredded.content_visible_while_pending_moderation
        !blocked?
      else
        approved?
      end
    end

    # Whether this is visible to the given user based on the moderation state.
    def moderation_state_visible_to_user?(user)
      moderation_state_visible_to_all? ||
        (!user.thredded_anonymous? &&
          (user_id == user.id || user.thredded_can_moderate_messageboard?(messageboard)))
    end

    private

    def set_default_moderation_state
      self.moderation_state ||= user_detail.moderation_state
    end
  end
end
