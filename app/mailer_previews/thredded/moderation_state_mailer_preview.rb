# frozen_string_literal: true

module Thredded
  # Previews for the PrivateTopicMailer
  class ModerationStateMailerPreview < BaseMailerPreview
    def moderation_state_notification
      ModerationStateMailer.moderation_state_notification(
        mock_user_detail,
        'glebm@test.com'
      )
    end
  end
end
