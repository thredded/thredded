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
      exclude_those_opting_out_of_followed_activity_notifications(possible_targeted_users, notifier)
    end

    def possible_targeted_users
      @post.postable.followers.reject { |u| u == @post.user }
    end

    private

    def exclude_those_opting_out_of_followed_activity_notifications(users, notifier)
      # TODO: ugly and super non-performant. but we can improve
      users.select do |user|
        (user.thredded_user_preference.notifications_for_followed_topics
          .find { |pref| pref.notifier_key == notifier.key } || defaults)
          .wants? &&
          (user.thredded_user_preference
            .messageboard_notifications_for_followed_topics.for_messageboard(@post.messageboard)
            .find { |pref| pref.notifier_key == notifier.key } || defaults)
            .wants?
      end
    end

    private

    # could be moved to notifer instance ? ...
    def defaults
      self.class.notifications_struct.new(true)
    end

    def self.notifications_struct
      @notifications_struct ||= Struct.new('NotificationsDefaults', :wants) do
        def wants?
          wants
        end
      end
    end
  end
end
