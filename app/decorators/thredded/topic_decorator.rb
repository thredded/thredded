# frozen_string_literal: true
module Thredded
  class TopicDecorator < SimpleDelegator
    def initialize(private_topic)
      super(Thredded::BaseTopicDecorator.new(private_topic))
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Topic')
    end

    def css_class
      classes = []
      classes << 'thredded--topic--locked' if locked?
      classes << 'thredded--topic--sticky' if sticky?
      classes += ['thredded--topic--category'] + categories.map { |c| "thredded--topic--category--#{c.name}" } if categories.present?
      classes.join(' ')
    end

    def category_options
      messageboard.decorate.category_options
    end
  end
end
