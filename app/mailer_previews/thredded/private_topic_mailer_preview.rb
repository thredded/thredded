# frozen_string_literal: true

module Thredded
  # Previews for the PrivateTopicMailer
  class PrivateTopicMailerPreview < BaseMailerPreview
    def message_notification
      post = mock_private_post(content: mock_content(mention_users: ['glebm']))
      PrivateTopicMailer.message_notification(
        mock_private_topic(posts: [
                             post
                           ]),
        post,
        %w[glebm@test.com joel@test.com]
      )
    end
  end
end
