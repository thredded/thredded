# frozen_string_literal: true

module Thredded
  module UserPermissions
    module Moderate
      module IfModeratorColumnTrue
        extend ActiveSupport::Concern

        # @return [ActiveRecord::Relation<Thredded::Messageboard>] messageboards that the user can moderate
        def thredded_can_moderate_messageboards
          send(Thredded.moderator_column) ? Thredded::Messageboard.all : Thredded::Messageboard.none
        end

        # @param [Thredded::Messageboard] messageboard
        # @return [Boolean] Whether the user can moderate the given messageboard.
        def thredded_can_moderate_messageboard?(messageboard)
          scope = thredded_can_moderate_messageboards
          scope == Thredded::Messageboard.all || scope.include?(messageboard)
        end
      end
    end
  end
end
