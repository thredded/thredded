# frozen_string_literal: true
module Thredded
  class NotifyPrivateTopicUsers
    def initialize(private_post)
      @post = private_post
      @private_topic = private_post.postable
    end

    def run
      members = private_topic_recipients

      return unless members.present?
      user_emails = members.map(&:email)
      PrivateTopicMailer
        .message_notification(private_topic.id, user_emails)
        .deliver_later
      mark_notified(members)
    end

    def private_topic_recipients
      members = private_topic.users - [post.user]
      members = exclude_those_opting_out_of_message_notifications(members)
      members = exclude_previously_notified(members)
      members
    end

    private

    attr_reader :post, :private_topic

    def mark_notified(members)
      members.each do |member|
        post.post_notifications.create(email: member.email)
      end
    end

    def exclude_those_opting_out_of_message_notifications(members)
      members.select { |member| member.thredded_user_preference.notify_on_message? }
    end

    def exclude_previously_notified(members)
      emails_notified = post.post_notifications.map(&:email)

      members.reject do |member|
        emails_notified.include? member.email
      end
    end
  end
end
