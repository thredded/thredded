module Thredded
  module UserPermissions
    module Read
      module All
        extend ActiveSupport::Concern
        included { extend ClassMethods }

        # @return [ActiveRecord::Relation] messageboards that the user can read
        def thredded_can_read_messageboards
          Thredded::Messageboard.all
        end

        module ClassMethods
          # Users that can read the given messageboards.
          #
          # @param _messageboards [Array<Thredded::Messageboard>]
          # @return [ActiveRecord::Relation] users that can read and post
          #     in the given messageboards
          def thredded_messageboards_readers(_messageboards)
            all
          end
        end
      end
    end
  end
end
