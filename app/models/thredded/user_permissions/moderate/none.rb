# frozen_string_literal: true

module Thredded
  module UserPermissions
    module Moderate
      module None
        extend ActiveSupport::Concern

        # @return [ActiveRecord::Relation<Thredded::Messageboard>] messageboards that the user can moderate
        def thredded_can_moderate_messageboards
          Thredded::Messageboard.none
        end

        # @param [Thredded::Messageboard] messageboard
        # @return [false] Whether the user can moderate the given messageboard.
        def thredded_can_moderate_messageboard?(messageboard) # rubocop:disable Lint/UnusedMethodArgument
          false
        end
      end
    end
  end
end
