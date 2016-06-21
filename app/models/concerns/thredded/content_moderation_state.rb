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

      scope :moderation_state_visible_to_all, -> { where(visible_to_all_arel_node) }

      scope :moderation_state_visible_to_user, (lambda do |user|
        visible = visible_to_all_arel_node
        # @type [Arel::Table]
        table = arel_table
        if user && !user.thredded_anonymous?
          # Own content
          visible = visible.or(table[:user_id].eq(user.id))
          # Content that one can moderate
          moderatable_messageboard_ids = user.thredded_can_moderate_messageboards.map(&:id)
          if moderatable_messageboard_ids.present?
            visible = visible.or(table[:messageboard_id].in(moderatable_messageboard_ids))
          end
        end
        where(visible)
      end)

      # @return [Arel::Nodes::Node]
      # @api private
      def self.visible_to_all_arel_node
        if Thredded.content_visible_while_pending_moderation
          # All non-blocked content
          arel_table[:moderation_state].not_eq(moderation_states[:blocked])
        else
          # Only approved content
          arel_table[:moderation_state].eq(moderation_states[:approved])
        end
      end
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
          (user_id == user.id || user.thredded_can_moderate_messageboards.map(&:id).include?(messageboard_id)))
    end

    private

    def set_default_moderation_state
      self.moderation_state ||= user_detail.moderation_state
    end
  end
end
