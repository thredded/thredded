# frozen_string_literal: true
module Thredded
  class ActivityUpdaterJob < ::ActiveJob::Base
    queue_as :default

    def perform(user_id, messageboard_id)
      now = Time.current

      user_detail = Thredded::UserDetail.where(user_id: user_id).first_or_initialize
      user_detail.update!(last_seen_at: now)

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
