require 'support/features/page_object/base'

module PageObject
  class Topics < Base
    attr_accessor :messageboard, :topic_title, :topic_content

    def initialize(messageboard)
      @messageboard = messageboard
    end

    def normal_topics
      all('article.topic:not(.locked):not(.sticky)')
    end

    def locked_topics
      all('.topics article.locked')
    end

    def stuck_topics
      all('.topics article.sticky')
    end

    def create_topic
      topic_with_content('Lorem ipsum dolor samet')
    end

    def create_bbcoded_topic
      topic_with_content('[b]Lorem[/b] ipsum dolor samet')
    end

    def rendering_bbcode?
      has_css? 'strong', text: 'Lorem'
    end

    def create_markdowned_topic
      topic_with_content('Lorem **ipsum** dolor samet')
    end

    def rendering_markdown?
      has_css? 'strong', text: 'ipsum'
    end

    def topic_with_content(post_content)
      visit_form
      title('Sample thread title')
      content(post_content)
      click_button 'Create New Topic'
    end

    def visit_style_guide
      visit theme_preview_path
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

    def has_topic_titled?(title)
      has_css?('article.topic h1 a', text: title)
    end

    def has_category_input?
      has_css? '.category select'
    end

    def has_a_locked_checkbox?
      has_css? 'label[for=topic_locked] input[type=checkbox]'
    end

    def has_a_sticky_checkbox?
      has_css? 'label[for=topic_sticky] input[type=checkbox]'
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
      create(:post, postable: topic)
    end

    def search_for(title)
      fill_in 'Search', with: title
      find('.thredded--user-navigation--search input[type="submit"]').click
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
