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
      members    = post.readers_from_user_names(user_names).to_a

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
        member.thredded_user_preference.notify_on_mention? &&
          (private_topic? || member.thredded_user_messageboard_preferences.in(post.messageboard).notify_on_mention?)
      end
    end

    def exclude_those_that_are_not_private(members)
      members.reject { |member| private_topic? && post.postable.users.exclude?(member) }
    end

    def exclude_previously_notified(members)
      emails_notified = Thredded::PostNotification.where(post: post).pluck(:email)
      members.reject { |member| emails_notified.include? member.email }
    end

    def private_topic?
      post.private_topic_post?
    end
  end
end
