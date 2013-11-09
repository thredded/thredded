require 'support/features/page_object/base'

module PageObject
  class PrivateTopics < Base
    def initialize(messageboard, title='this is private')
      @messageboard = messageboard
      @private_title = title
    end

    def visit_index
      visit messageboard_private_topics_path(messageboard)
    end

    def private_topics
      all('.topics article.private')
    end

    def create_private_topic
      visit new_messageboard_private_topic_path(messageboard)
      fill_in 'Title', with: private_title
      select 'carl', from: 'topic_user_id'
      fill_in 'Content', with: 'not for others'

      click_on 'Create New Private Topic'
    end

    def visit_private_topic_list
      visit messageboard_private_topics_path(messageboard)
    end


    def on_public_list?
      visit messageboard_topics_path(messageboard)

      has_css? 'article h1 a', text: private_title
    end

    def on_private_list?
      visit messageboard_private_topics_path(messageboard)

      has_css? 'article h1 a', text: private_title
    end

    alias_method :private_topic, :private_topics

    private

    attr_reader :messageboard, :private_title
  end
end

