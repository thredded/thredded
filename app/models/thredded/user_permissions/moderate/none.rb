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
      end
    end
  end
end
