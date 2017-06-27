# frozen_string_literal: true

module Thredded
  class NotifyPrivateTopicUsers
    def initialize(private_post)
      @post = private_post
      @private_topic = private_post.postable
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifiable_users = targeted_users(notifier)
        notifier.new_private_post(@post, notifiable_users) if notifiable_users.present?
      end
    end

    def targeted_users(notifier)
      users = private_topic.users.includes(:thredded_notifications_for_private_topics) - [post.user]
      users = only_those_with_this_notifier_enabled(users, notifier)
      users
    end

    private

    attr_reader :post, :private_topic

    def only_those_with_this_notifier_enabled(users, notifier)
      users.select do |user|
        Thredded::NotificationsForPrivateTopics
          .detect_or_default(user.thredded_notifications_for_private_topics, notifier).enabled?
      end
    end
  end
end
