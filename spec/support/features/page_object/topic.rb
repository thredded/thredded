require 'support/features/page_object/base'

module PageObject
  class Topic < Base
    attr_accessor :messageboard, :topic

    def initialize(topic)
      @topic = topic
      @messageboard = topic.messageboard
    end

    def posts
      topic.posts
    end

    def visit_topic
      visit messageboard_topic_path(messageboard, topic)
    end

    def visit_topic_edit
      visit edit_messageboard_topic_path(messageboard, topic)
    end

    def editable?
      has_css? "form#edit_topic_#{topic.id}"
    end

    def deletable?
      has_button? 'Delete Topic'
    end

    def listed?
      all('a', text: topic.title).any?
    end

    def change_title_to(title)
      fill_in 'Title', with: title
    end

    def make_locked
      check 'Locked'
    end

    def submit
      click_button 'Update Topic'
    end

    def delete
      click_button 'Delete Topic'
    end

    def locked?
      has_css?('.thredded--topic.thredded--topic--locked')
    end

    def has_redirected_after_delete?
      has_content?('Topic deleted')
    end
  end
end
