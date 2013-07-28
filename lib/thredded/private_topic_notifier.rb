module Thredded
  class PrivateTopicNotifier
    def initialize(topic)
      @post = topic.posts.first || Post.new
      @topic = topic
    end

    def notifications_for_private_topic
      members = private_topic_recipients

      if members.present?
        user_emails = members.map(&:email)
        TopicMailer.message_notification(topic.id, user_emails).deliver
        mark_notified(members)
      end
    end

    def private_topic_recipients
      members = topic.users - [topic.user]
      members = exclude_those_opting_out_of_message_notifications(members)
      members = exclude_previously_notified(members)
      members
    end

    private

    attr_reader :post, :topic

    def mark_notified(members)
      members.each do |member|
        post.post_notifications.create(email: member.email)
      end
    end

    def exclude_those_opting_out_of_message_notifications(members)
      members.reject do |member|
        !Thredded::MessageboardPreference
          .for(member)
          .in(topic.messageboard)
          .first
          .try(:notify_on_message?)
      end
    end

    def notify_for_member_in_messageboard?(member, messageboard)
    end

    def exclude_previously_notified(members)
      emails_notified = post.post_notifications.map(&:email)

      members.reject do |member|
        emails_notified.include? member.email
      end
    end
  end
end
