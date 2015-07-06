require 'thredded/base_topic_decorator'

module Thredded
  class TopicDecorator < SimpleDelegator
    def initialize(topic)
      super(Thredded::BaseTopicDecorator.new(topic))
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Topic')
    end

    def self.decorate_all(topics)
      topics.map do |topic|
        new(topic)
      end
    end

    def css_class
      classes = []
      classes << 'locked' if locked?
      classes << 'sticky' if sticky?
      classes += ['category'] + categories.map(&:name) if categories.present?
      classes.join(' ')
    end

    def category_options
      messageboard.decorate.category_options
    end
  end
end
