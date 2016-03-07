require 'support/features/page_object/base'

module PageObject
  class PrivateTopics < Base
    def initialize(messageboard, title = 'this is private')
      @messageboard = messageboard
      @private_title = title
    end

    def visit_index
      visit messageboard_private_topics_path(messageboard)
    end

    def view_private_topic
      click_on @private_title
    end

    def private_topics
      all('article.thredded--private-topic')
    end

    def read_private_topics
      all('.thredded--topic--read.thredded--private-topic')
    end

    def unread_private_topics
      all('.thredded--topic--unread.thredded--private-topic')
    end

    def create_private_topic
      visit new_messageboard_private_topic_path(messageboard)
      fill_in 'Title', with: private_title
      select 'carl', from: 'private_topic_user_ids'
      fill_in 'Content', with: 'not for others'

      click_on 'Create New Private Topic'
    end

    def update_all_private_topics
      Thredded::PrivateUser.update_all(read: false)
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
    alias_method :unread_private_topic, :unread_private_topics

    private

    attr_reader :messageboard, :private_title
  end
end
