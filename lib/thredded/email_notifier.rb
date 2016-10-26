# frozen_string_literal: true
module Thredded
  class EmailNotifier
    def new_post(post, users)
      PostMailer.post_notification(post.id, users.map(&:email)).deliver_now
      MembersMarkedNotified.new(post, users).run
    end

    def new_private_post(post, users)
      @post = post
      @topic = post.postable
      send_to = private_topic_recipients(users)
      return unless send_to.present?
      user_emails = send_to.map(&:email)
      PrivateTopicMailer
        .message_notification(post.postable.id, user_emails)
        .deliver_later
      MembersMarkedNotified.new(post, send_to).run
    end

    def private_topic_recipients(users)
      users = exclude_those_opting_out_of_message_notifications(users)
      users = exclude_previously_notified(users)
      users
    end

    private

    attr_reader :post, :topic


    def exclude_those_opting_out_of_message_notifications(users)
      users.select { |user| user.thredded_user_preference.notify_on_message? }
    end

    def exclude_previously_notified(users)
      emails_notified = post.post_notifications.map(&:email)

      users.reject do |user|
        emails_notified.include? user.email
      end
    end
  end
end
