# frozen_string_literal: true
module Thredded
  # Previews for the PrivateTopicMailer
  class PrivateTopicMailerPreview < BaseMailerPreview
    def message_notification
      PrivateTopicMailer.message_notification(
        mock_private_topic.tap do |private_topic|
          private_topic.posts = [
            mock_private_post(content: mock_content(mention_users: ['glebm']), postable: private_topic)
          ]
        end,
        %w(glebm@test.com joel@test.com))
    end
  end
end
