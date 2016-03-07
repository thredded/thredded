module Thredded
  class MessageboardDecorator < SimpleDelegator
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TagHelper

    def initialize(messageboard)
      super
      @messageboard = messageboard
    end

    def original
      messageboard
    end

    def meta
      topics_count = number_to_human(messageboard.topics_count)
      posts_count = number_to_human(messageboard.posts_count)

      "#{topics_count} topics / #{posts_count} posts".downcase
    end

    def latest_topic
      @latest_topic ||= begin
        messageboard.topics.order_latest_first.first ||
          Thredded::NullTopic.new
      end
    end

    def latest_user
      latest_topic.last_user
    end

    def category_options
      messageboard.categories.map { |cat| [cat.name, cat.id] }
    end

    private

    attr_reader :messageboard

    def topic_updated_at_utc
      latest_topic.updated_at.getutc.iso8601
    end

    def topic_updated_at_str
      latest_topic.updated_at.to_s
    end
  end
end
