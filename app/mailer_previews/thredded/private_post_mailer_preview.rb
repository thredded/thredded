# frozen_string_literal: true
module Thredded
  # Previews for the PrivatePostMailer
  class PrivatePostMailerPreview < BaseMailerPreview
    def at_notification
      PrivatePostMailer.at_notification(
        mock_private_post(content: mock_content(mention_users: %w(glebm joel))),
        %w(glebm@test.com joel@test.com))
    end
  end
end
