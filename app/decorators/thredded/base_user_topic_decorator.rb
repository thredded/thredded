# frozen_string_literal: true
module Thredded
  class BaseUserTopicDecorator < SimpleDelegator
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    class << self
      # @return [Class<ActiveRecord::Base>]
      def topic_class
        fail 'Implement in subclass'
      end

      def decorator_class
        "#{topic_class.name}Decorator".constantize
      end

      def decorate_all(user, topics)
        topics.map { |topic| new(user, topic) }
      end

      def model_name
        ActiveModel::Name.new(self, nil, topic_class.name.demodulize)
      end
    end

    def initialize(user, topic)
      @user  = user || Thredded::NullUser.new
      @topic = self.class.decorator_class.new(topic)
      super(@topic)
    end

    def to_model
      topic
    end

    def persisted?
      false
    end

    def css_class
      [read_status_class, topic.css_class].map(&:presence).compact.join(' ')
    end

    def read_status_class
      if read?
        'thredded--topic--read'
      else
        'thredded--topic--unread'
      end
    end

    def read?
      fail 'Subclass responsibility'
    end

    def to_ary
      [self]
    end

    private

    attr_reader :topic, :user
  end
end
