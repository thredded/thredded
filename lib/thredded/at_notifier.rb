require 'thredded/at_notification_extractor'

module Thredded
  class AtNotifier
    def initialize(post)
      @post = post
    end

    def notifications_for_at_users
      members = at_notifiable_members

      if members.present?
        user_emails = members.map(&:email)
        Thredded::PostMailer.at_notification(post.id, user_emails).deliver
        mark_notified(members)
      end
    end

    def at_notifiable_members
      at_names = Thredded::AtNotificationExtractor.new(post.content).extract
      members = post.messageboard.members_from_list(at_names).to_a

      members.delete post.user
      members = exclude_previously_notified(members)
      members = exclude_those_that_are_not_private(members)
      members = exclude_those_opting_out_of_at_notifications(members)

      members
    end

    private

    attr_reader :post

    def exclude_those_opting_out_of_at_notifications(members)
      members.select do |member|
        Thredded::MessageboardPreference
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
        .where(post_id: post.id)
        .map(&:email)

      members.reject do |member|
        emails_notified.include? member.email
      end
    end

    def mark_notified(members)
      members.each do |member|
        post.post_notifications.create(email: member.email)
      end
    end

    def private_topic?
      post.postable.private?
    end
  end
end
