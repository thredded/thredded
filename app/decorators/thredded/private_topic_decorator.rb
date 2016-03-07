require 'thredded/base_topic_decorator'

module Thredded
  class PrivateTopicDecorator < SimpleDelegator
    def initialize(private_topic)
      super BaseTopicDecorator.new(private_topic)
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'PrivateTopic')
    end

    def to_model
      __getobj__
    end

    def css_class
      classes = []
      classes << 'thredded--private-topic'
      classes.join(' ')
    end
  end
end
