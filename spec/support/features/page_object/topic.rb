require 'support/features/page_object/base'

module PageObject
  class Topic < Base
    attr_accessor :messageboard

    def initialize(messageboard)
      @messageboard = messageboard
    end

    def visit_index
      visit messageboard_topics_path(messageboard)
    end

    def normal_topics
      all('.topics article:not([class])')
    end

    def locked_topic
      all('.topics article.locked')
    end

    def stuck_topic
      all('.topics article.sticky')
    end
  end
end
