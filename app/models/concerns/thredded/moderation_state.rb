# frozen_string_literal: true

module Thredded
  # Defines a moderation_state enum
  # Requires an integer moderation_state column on the including class.
  module ModerationState
    extend ActiveSupport::Concern

    included do
      if Thredded::Compat.rails_gte_7?
        enum :moderation_state, %i[pending_moderation approved blocked]
      else
        enum moderation_state: %i[pending_moderation approved blocked]
      end
      validates :moderation_state, presence: true
    end
  end
end
