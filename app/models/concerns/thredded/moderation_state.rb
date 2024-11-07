# frozen_string_literal: true

module Thredded
  # Defines a moderation_state enum
  # Requires an integer moderation_state column on the including class.
  module ModerationState
    extend ActiveSupport::Concern

    included do
      enum :moderation_state, %i[pending_moderation approved blocked]
      validates :moderation_state, presence: true
    end
  end
end
