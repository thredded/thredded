require 'support/features/page_object/base'

module PageObject
  class Topics < Base
    attr_accessor :messageboard, :topic_title, :topic_content


    def initialize(messageboard)
      @messageboard = messageboard
    end

    def normal_topics
      all('.topics article[class="topic read "]')
    end

    def locked_topic
      all('.topics article.locked')
    end

    def stuck_topic
      all('.topics article.sticky')
    end

    def create_topic
      visit_form
      title('Sample thread title')
      content('Lorem ipsum dolor samet')
      click_button 'Create New Topic'
    end

    def visit_index
      visit messageboard_topics_path(messageboard)
    end

    def visit_form
      visit new_messageboard_topic_path(messageboard)
    end

    def visit_latest_topic
      visit messageboard_topic_path(messageboard, Thredded::Topic.last)
    end

    def visit_topic_edit
      visit edit_messageboard_topic_path(messageboard)
    end

    def listed?
      has_css?('a', text: topic_title)
    end

    def displayed?
      has_content?(topic_title) && has_content?(topic_content)
    end

    alias_method :has_the_title_and_content?, :displayed?

    def has_category_input?
      has_css? '.category select'
    end

    def has_a_locked_checkbox?
      has_css? '.locked input'
    end

    def has_a_sticky_checkbox?
      has_css? '.sticky input'
    end

    def locked?
      has_css? '.topic.locked'
    end

    def stuck?
      has_css? '.topic.sticky'
    end

    def categorized?
      has_css? '.topic.category'
    end

    def with_title(text)
      title text
    end

    def with_content(text)
      content text
    end

    def make_locked
      find('input[type="hidden"][name="topic[locked]"]').set('1')
    end

    def make_sticky
      find('input[type="hidden"][name="topic[sticky]"]').set('1')
    end

    def select_category(category)
      select category, from: 'topic_category_ids'
    end

    def submit
      click_button 'Create New Topic'
    end

    def read?
      has_css? '.topics article.read h1 a', text: topic_title
    end

    def view_topic
      find('.topics h1 a').click
    end

    def view_read_topic
      visit_index
      view_topic
    end

    def someone_updates_topic
      topic = Thredded::Topic.last
      create(:post, topic: topic)
    end

    private

    def title(text)
      self.topic_title = text
      fill_in 'Title', with: text
    end

    def content(text)
      self.topic_content = text
      fill_in 'Content', with: text
    end
  end
end
