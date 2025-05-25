# frozen_string_literal: true

module Thredded
  # Defines a moderation_state enum
  # Requires an integer moderation_state column on the including class.
  module ModerationState
    extend ActiveSupport::Concern

    included do
      enum :moderation_state, { pending_moderation: 0, approved: 1, blocked: 2 }
      validates :moderation_state, presence: true
    end
  end
end
