require 'support/features/page_object/base'

module PageObject
  class PrivateTopics < Base
    def initialize(messageboard)
      @messageboard = messageboard
    end

    def visit_index
      visit messageboard_private_topics_path(messageboard)
    end

    def private_topics
      all('.topics article.private')
    end

    alias_method :private_topic, :private_topics

    private

    attr_reader :messageboard
  end
end

