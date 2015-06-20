module Thredded
  class EnsureRoleExistsJob
    include Q::Methods

    queue(:for_user_and_messageboard) do |user_id, messageboard_id|
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          user = Thredded.user_class.find(user_id)
          messageboard = Messageboard.find(messageboard_id)

          EnsureRoleExists
            .new(user: user, messageboard: messageboard)
            .run

        rescue ActiveRecord::RecordNotFound
          # NOOP
        end
      end
    end
  end
end
