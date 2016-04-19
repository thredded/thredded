# frozen_string_literal: true
module Thredded
  class UserPrivateTopicDecorator < BaseUserTopicDecorator
    def self.topic_class
      PrivateTopic
    end
  end
end
