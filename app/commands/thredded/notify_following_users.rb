# frozen_string_literal: true
module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifiable_users = targeted_users(notifier)
        notifier.new_post(@post, notifiable_users) if notifiable_users.present?
      end
    end

    def targeted_users(notifier)
      possible_targeted_users.select do |user|
        NotificationsForFollowedTopics
          .detect_or_default(user.thredded_notifications_for_followed_topics, notifier).enabled? &&
          MessageboardNotificationsForFollowedTopics
            .detect_or_default(messageboard_notifier_prefs_by_user_id[user.id], notifier).enabled?
      end
    end

    def possible_targeted_users
      @possible_targeted_users ||=
        @post.postable.followers.includes(:thredded_notifications_for_followed_topics).reject { |u| u == @post.user }
    end

    private

    def messageboard_notifier_prefs_by_user_id
      @messageboard_notifier_prefs_by_user_id ||= MessageboardNotificationsForFollowedTopics
        .where(user_id: possible_targeted_users.map(&:id))
        .for_messageboard(@post.messageboard).group_by(&:user_id)
    end
  end
end
