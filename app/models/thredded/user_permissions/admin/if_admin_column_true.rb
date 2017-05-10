# frozen_string_literal: true

module Thredded
  module UserPermissions
    module Admin
      module IfAdminColumnTrue
        # @return [boolean] Whether this user has full admin rights on Thredded.
        def thredded_admin?
          send(Thredded.admin_column)
        end
      end
    end
  end
end
