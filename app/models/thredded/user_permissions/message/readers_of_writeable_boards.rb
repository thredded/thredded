# frozen_string_literal: true
module Thredded
  module UserPermissions
    module Message
      module ReadersOfWriteableBoards
        # @return [ActiveRecord::Relation<Thredded.user_class>] the users this user can include in a private topic
        def thredded_can_message_users
          # By default, return everyone who can read the messageboards this user can post in
          Thredded.user_class.thredded_messageboards_readers(thredded_can_write_messageboards)
        end
      end
    end
  end
end
