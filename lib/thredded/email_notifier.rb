# frozen_string_literal: true
module Thredded
  class EmailNotifier
    def new_post(post, users)
      PostMailer.post_notification(post.id, users.map(&:email)).deliver_now
      MembersMarkedNotified.new(post, users).run
    end

    def new_private_post(post, users)
      users = exclude_previously_notified(post, users)
      return unless users.present?
      PrivateTopicMailer
        .message_notification(post.postable.id, users.map(&:email))
        .deliver_now
      MembersMarkedNotified.new(post, users).run
    end

    def exclude_previously_notified(post, users)
      emails_notified = post.post_notifications.map(&:email)

      users.reject do |user|
        emails_notified.include? user.email
      end
    end
  end
end
