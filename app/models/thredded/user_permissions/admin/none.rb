# frozen_string_literal: true

module Thredded
  module UserPermissions
    module Admin
      module None
        # @return [boolean] Whether this user has full admin rights on Thredded.
        def thredded_admin?
          false
        end
      end
    end
  end
end
