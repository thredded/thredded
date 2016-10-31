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
      users = private_topic.users - [post.user]
      users = exclude_those_opting_out_of_message_notifications(users, notifier)
      users
    end

    private

    attr_reader :post, :private_topic

    def exclude_those_opting_out_of_message_notifications(users, notifier)
      users.select do |user|
        user.thredded_user_preference.notifications_for_private_topics[notifier.key]
      end
    end
  end
end
