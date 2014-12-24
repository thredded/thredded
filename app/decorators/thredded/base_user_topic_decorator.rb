module Thredded
  class BaseUserTopicDecorator < Module
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    delegate :created_at_timeago, :last_user_link, :original, :updated_at_timeago, to: :topic

    class << self
      # @return [Class<ActiveRecord::Base>]
      def topic_class
        fail 'Implement in subclass'
      end

      def decorator_class
        "#{topic_class.name}Decorator".constantize
      end

      def decorate_all(user, topics)
        topics.map do |topic|
          new(user, topic)
        end
      end

      def model_name
        ActiveModel::Name.new(self, nil, self.topic_class.name.demodulize)
      end
    end

    def initialize(user, topic)
      @user  = user || NullUser.new
      @topic = self.class.decorator_class.new(topic)
    end

    def method_missing(meth, *args)
      if topic.respond_to?(meth)
        topic.send(meth, *args)
      else
        super
      end
    end

    def respond_to?(meth)
      super || topic.respond_to?(meth)
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
        'read'
      else
        'unread'
      end
    end

    def read?
      fail 'Subclass responsibility'
    end

    private

    attr_reader :topic, :user
  end
end
