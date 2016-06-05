# frozen_string_literal: true
module Thredded
  # Moderation state of a piece of content, such as a Topic or a Post.
  # Requires an integer moderation_state column, a user_id column, and a user_detail association on the including class.
  # @api private
  module ContentModerationState
    extend ActiveSupport::Concern
    include ModerationState

    included do
      before_validation :set_default_moderation_state, on: :create

      scope :moderation_state_visible_to_user, (lambda do |user|
        # @type [Arel::Table]
        table = arel_table
        # @type [Arel::Nodes::Node]
        visible_to_all =
          if Thredded.content_visible_while_pending_moderation
            table[:moderation_state].not_eq(moderation_states[:blocked])
          else
            table[:moderation_state].eq(moderation_states[:approved])
          end
        where(
          if user && !user.thredded_anonymous?
            visible_to_all.or(table[:user_id].eq(user.id))
          else
            visible_to_all
          end
        )
      end)
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
      moderation_state_visible_to_all? || (!user.thredded_anonymous? && user_id == user.id)
    end

    private

    def set_default_moderation_state
      self.moderation_state ||= user_detail.moderation_state
    end
  end
end
