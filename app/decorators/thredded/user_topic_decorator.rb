# frozen_string_literal: true
module Thredded
  class UserTopicDecorator < BaseUserTopicDecorator
    def self.topic_class
      Topic
    end
  end
end
