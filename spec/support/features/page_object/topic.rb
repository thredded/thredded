require 'support/features/page_object/base'

module PageObject
  class Topic < Base
    attr_accessor :messageboard, :topic

    def initialize(topic)
      @topic = topic
      @messageboard = topic.messageboard
    end

    def visit_topic_edit
      visit edit_messageboard_topic_path(messageboard, topic)
    end

    def editable?
      has_css? 'input#topic_title'
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

    def locked?
      has_css?('.topic.locked')
    end
  end
end
