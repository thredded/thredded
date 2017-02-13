# frozen_string_literal: true
require 'set'

module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifiable_users = targeted_users(notifier)
        notifiable_users = notifiable_users.select do |user|
          # Create a notification for the user.
          # If a notification was already created (from another thread/process),
          # this will return false due to the unique constraint on the table
          # and the user will be excluded.
          Thredded::UserPostNotification.create_from_post_and_user(@post, user)
        end
        next if notifiable_users.empty?
        notifier.new_post(@post, notifiable_users)
      end
    end

    def targeted_users(notifier)
      users_subscribed_via(notifier).reject do |user|
        already_notified_user_ids.include?(user.id)
      end
    end

    def users_subscribed_via(notifier)
      subscribed_users.select do |user|
        NotificationsForFollowedTopics
          .detect_or_default(user.thredded_notifications_for_followed_topics, notifier).enabled? &&
          MessageboardNotificationsForFollowedTopics
            .detect_or_default(messageboard_notifier_prefs_by_user_id[user.id], notifier).enabled?
      end
    end

    def subscribed_users
      @subscribed_users ||=
        @post.postable.followers.includes(:thredded_notifications_for_followed_topics).reject do |user|
          user == @post.user || !Thredded::PostPolicy.new(user, @post).read?
        end
    end

    def already_notified_user_ids
      @notified_user_ids ||= Set.new Thredded::UserPostNotification.notified_user_ids(@post)
    end

    private

    def messageboard_notifier_prefs_by_user_id
      @messageboard_notifier_prefs_by_user_id ||= MessageboardNotificationsForFollowedTopics
        .where(user_id: subscribed_users.map(&:id))
        .for_messageboard(@post.messageboard).group_by(&:user_id)
    end
  end
end
