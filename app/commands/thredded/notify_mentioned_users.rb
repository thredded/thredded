module Thredded
  class NotifyMentionedUsers
    def initialize(post)
      @post = post
    end

    def run
      members = at_notifiable_members
      return unless members.present?

      user_emails = members.map(&:email)
      (post.private_topic_post? ? PrivatePostMailer : PostMailer)
        .at_notification(post.id, user_emails)
        .deliver_later
      MembersMarkedNotified.new(post, members).run
    end

    def at_notifiable_members
      user_names = AtNotificationExtractor.new(post.content).run
      members = post.readers_from_user_names(user_names).to_a

      members.delete post.user
      members = exclude_previously_notified(members)
      members = exclude_those_that_are_not_private(members)
      members = exclude_those_opting_out_of_at_notifications(members)

      members
    end

    private

    attr_reader :post

    def exclude_those_opting_out_of_at_notifications(members)
      # TODO: implement global notification preferences for private topics.
      return members if private_topic?
      members.select do |member|
        Thredded::NotificationPreference
          .for(member)
          .in(post.messageboard)
          .first_or_create
          .notify_on_mention?
      end
    end

    def exclude_those_that_are_not_private(members)
      members.reject do |member|
        private_topic? && post.postable.users.exclude?(member)
      end
    end

    def exclude_previously_notified(members)
      emails_notified = Thredded::PostNotification
        .where(post: post)
        .pluck(:email)

      members.reject do |member|
        emails_notified.include? member.email
      end
    end

    def private_topic?
      post.private_topic_post?
    end
  end
end
