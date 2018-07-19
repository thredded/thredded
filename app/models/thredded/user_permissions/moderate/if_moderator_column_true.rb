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
      end
    end
  end
end
