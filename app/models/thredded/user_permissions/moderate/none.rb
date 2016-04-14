# frozen_string_literal: true
module Thredded
  module UserPermissions
    module Moderate
      module None
        extend ActiveSupport::Concern
        included { extend ClassMethods }

        # @return [ActiveRecord::Relation<Thredded::Messageboard>] messageboards that the user can moderate
        def thredded_can_moderate_messageboards
          Thredded::Messageboard.none
        end

        module ClassMethods
          # Users that can moderate the given messageboards.
          #
          # @param _messageboards [Array<Thredded::Messageboard>]
          # @return [ActiveRecord::Relation<Thredded.user_class>] users that can moderate the given messageboards
          def thredded_messageboards_moderators(_messageboards)
            none
          end
        end
      end
    end
  end
end
