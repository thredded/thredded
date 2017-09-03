# frozen_string_literal: true

require 'set'

module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      subscribed_users.select! do |user|
        # Record idempotently that the notification happened.
        # If a notification was already created (e.g. from another thread/process),
        # this will return false due to the unique constraint on the table
        # and the user will be excluded.
        subscribed_via_any_notifier?(user) && record_as_notified_successful?(user)
      end
      Thredded.notifiers.each do |notifier|
        notifiable_users = targeted_users(notifier)
        next if notifiable_users.empty?
        notifier.new_post(@post, notifiable_users)
      end
    end

    def targeted_users(notifier)
      subscribed_users.select do |user|
        user_subscribed_via?(user, notifier)
      end
    end

    def user_subscribed_via?(user, notifier)
      Thredded::NotificationsForFollowedTopics
        .detect_or_default(user.thredded_notifications_for_followed_topics, notifier).enabled? &&
        Thredded::MessageboardNotificationsForFollowedTopics
          .detect_or_default(messageboard_notifier_prefs_by_user_id[user.id], notifier).enabled?
    end

    # @return [Array<User>]
    def subscribed_users
      @subscribed_users ||=
        @post.postable.followers.includes(:thredded_notifications_for_followed_topics).select do |user|
          !already_notified?(user) && !originator?(user) && can_read_post?(user)
        end
    end

    private

    def originator?(user)
      user == @post.user
    end

    def can_read_post?(user)
      Thredded::PostPolicy.new(user, @post).read?
    end

    def already_notified?(user)
      # We memoize the set so that records created during this task do not affect the result,
      # so that a user can receive notifications via multiple notifiers.
      @already_notified_user_ids ||= Set.new Thredded::UserPostNotification.notified_user_ids(@post)
      @already_notified_user_ids.include?(user.id)
    end

    def subscribed_via_any_notifier?(user)
      Thredded.notifiers.any? { |notifier| user_subscribed_via?(user, notifier) }
    end

    def record_as_notified_successful?(user)
      Thredded::UserPostNotification.create_from_post_and_user(@post, user)
    end

    def messageboard_notifier_prefs_by_user_id
      @messageboard_notifier_prefs_by_user_id ||= Thredded::MessageboardNotificationsForFollowedTopics
        .where(user_id: subscribed_users.map(&:id))
        .for_messageboard(@post.messageboard).group_by(&:user_id)
    end
  end
end
