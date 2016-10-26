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
        notifier.new.new_private_post(@post, notifiable_users) if notifiable_users.present?
      end
    end

    def targeted_users(notifier)
      users = private_topic.users - [post.user]
      return users unless notifier == EmailNotifier
      users = exclude_those_opting_out_of_message_notifications(users)
      users
    end

    private

    attr_reader :post, :private_topic

    def exclude_those_opting_out_of_message_notifications(users)
      users.select { |user| user.thredded_user_preference.notify_on_message? }
    end
  end
end
