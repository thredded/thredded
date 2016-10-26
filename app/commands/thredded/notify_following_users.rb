# frozen_string_literal: true
module Thredded
  class NotifyFollowingUsers
    def initialize(post)
      @post = post
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifiable_users = targeted_users(notifier)
        notifier.new.new_post(@post, notifiable_users) if notifiable_users.present?
      end
    end

    def targeted_users(notifier)
      exclude_those_opting_out_of_followed_activity_notifications(possible_targeted_users, notifier)
    end

    def possible_targeted_users
      @post.postable.followers.reject { |u| u == @post.user }
    end

    private

    def exclude_those_opting_out_of_followed_activity_notifications(users, notifier)
      return users unless notifier == EmailNotifier
      users.select do |user|
        user.thredded_user_preference.followed_topic_emails &&
          user.thredded_user_messageboard_preferences.in(@post.messageboard).followed_topic_emails
      end
    end
  end
end
