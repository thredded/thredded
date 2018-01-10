# frozen_string_literal: true

module Thredded
  class ActivityUpdaterJob < ::ActiveJob::Base
    queue_as :default

    def perform(user_id, messageboard_id)
      now = Time.current

      begin
        user_detail = Thredded::UserDetail.find_or_initialize_by(user_id: user_id)
        user_detail.update!(last_seen_at: now)
      rescue ActiveRecord::RecordNotUnique
        # The record has been created from another connection, retry to find it.
        retry
      end

      begin
        Thredded::MessageboardUser
          .find_or_initialize_by(
            thredded_messageboard_id: messageboard_id,
            thredded_user_detail_id: user_detail.id
          )
          .update!(last_seen_at: now)
      rescue ActiveRecord::RecordNotUnique
        # The record has been created from another connection, retry to find it.
        retry
      end
    end
  end
end
