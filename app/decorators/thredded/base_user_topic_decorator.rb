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
        if user.thredded_anonymous?
          topics.map { |topic| new(topic, user) }
        else
          read_state_by_topic_id =
            topics.reflect_on_association(:user_read_states).klass
              .where(user_id: user.id, postable_id: topics.map(&:id))
              .group_by(&:postable_id)
          topics.map do |topic|
            read_state = read_state_by_topic_id[topic.id]
            new(topic, read_state && read_state[0])
          end
        end
      end

      def model_name
        ActiveModel::Name.new(self, nil, topic_class.name.demodulize)
      end
    end

    def initialize(topic, read_state_or_user)
      if read_state_or_user.respond_to?(:thredded_anonymous?)
        unless read_state_or_user.thredded_anonymous?
          @read_state =
            topic.association(:user_read_states).klass
              .where(user_id: read_state_or_user.id, postable_id: topic.id).first
        end
      else
        @read_state = read_state_or_user
      end
      @read_state ||= Thredded::NullUserTopicReadState.new
      @topic = self.class.decorator_class.new(topic)
      super(@topic)
    end

    def to_model
      @topic
    end

    def persisted?
      false
    end

    def css_class
      [(read? ? 'thredded--topic--read' : 'thredded--topic--unread'), @topic.css_class].join(' ')
    end

    def read?
      @read_state.read?
    end

    def farthest_page
      @read_state.page
    end

    def to_ary
      [self]
    end
  end
end
