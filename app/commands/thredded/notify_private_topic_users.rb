# frozen_string_literal: true
module Thredded
  class NotifyPrivateTopicUsers
    def initialize(private_post)
      @post = private_post
      @private_topic = private_post.postable
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifier.new.new_private_post(@post, private_topic_recipients)
      end
    end

    def private_topic_recipients
      private_topic.users - [post.user]
    end

    private

    attr_reader :post, :private_topic
  end
end
