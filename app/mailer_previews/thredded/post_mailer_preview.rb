module Thredded
  # Previews for the PostMailer
  class PostMailerPreview < BaseMailerPreview
    def at_notification
      PostMailer.at_notification(
        mock_post(content: mock_content(mention_users: %w(glebm joel))),
        %w(glebm@test.com joel@test.com))
    end
  end
end
