# frozen_string_literal: true
module Thredded
  class ActivityUpdaterJob < ::ActiveJob::Base
    queue_as :default

    def perform(user_id, messageboard_id)
      now = Time.zone.now

      user_detail = Thredded::UserDetail.for_user_id(user_id)
      user_detail.update_column(:last_seen_at, now)

      Thredded::MessageboardUser
        .where(
          thredded_messageboard_id: messageboard_id,
          thredded_user_detail_id: user_detail.id
        )
        .first_or_initialize
        .update!(last_seen_at: now)
    end
  end
end
