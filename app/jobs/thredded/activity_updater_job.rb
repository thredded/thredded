module Thredded
  class ActivityUpdaterJob
    include Q::Methods

    queue(:update_user_activity) do |options|
      now = Time.zone.now
      ActiveRecord::Base.connection_pool.with_connection do
        user_detail = Thredded::UserDetail.for_user_id(options['user_id'])
        user_detail.update_column(:last_seen_at, now)
        Thredded::MessageboardUser
          .where(thredded_messageboard_id: options['messageboard_id'], thredded_user_detail_id: user_detail.id)
          .first_or_initialize
          .update!(last_seen_at: now)
      end
    end
  end
end
