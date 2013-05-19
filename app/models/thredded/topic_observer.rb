require 'thredded/private_topic_notifier'

module Thredded
  class TopicObserver < ActiveRecord::Observer
    def after_save(topic)
      PrivateTopicNotifier.new(topic).notifications_for_private_topic
    end
  end
end
